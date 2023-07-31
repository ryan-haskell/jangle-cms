port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , map, toCmd
    , saveOAuthResponse
    , fetchSupabaseUser
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs map, toCmd


## Custom effects

@docs saveOAuthResponse
@docs fetchSupabaseUser

-}

import Auth.User
import Browser.Navigation
import Dict exposing (Dict)
import Json.Encode
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg
import Supabase.Auth
import Supabase.Context
import Supabase.OAuthResponse
import Task
import Url exposing (Url)


type Effect msg
    = -- BASICS
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- ROUTING
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- SHARED
    | SendSharedMsg Shared.Msg.Msg
      -- LOCAL STORAGE
    | Save
        { key : String
        , value : Json.Encode.Value
        }
      -- SUPABASE
    | Supabase SupabaseRequest



-- BASICS


{-| Don't send any effect.
-}
none : Effect msg
none =
    None


{-| Send multiple effects at once.
-}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| Send a normal `Cmd msg` as an effect, something like `Http.get` or `Random.generate`.
-}
sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


{-| Send a message as an effect. Useful when emitting events from UI components.
-}
sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


{-| Set the new route, and make the back button go back to the current route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


{-| Set the new route, but replace the previous one, so clicking the back
button **won't** go back to the previous route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


{-| Redirect users to a new URL, somewhere external your web application.
-}
loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl



-- LOCAL STORAGE


saveOAuthResponse : Supabase.OAuthResponse.OAuthResponse -> Effect msg
saveOAuthResponse oauthResponse =
    Save
        { key = "oAuthResponse"
        , value = Supabase.OAuthResponse.encode oauthResponse
        }



-- SUPABASE


type SupabaseRequest
    = FetchSupabaseUser


fetchSupabaseUser : Effect msg
fetchSupabaseUser =
    Supabase FetchSupabaseUser



-- INTERNALS


{-| Elm Land depends on this function to connect pages and layouts
together into the overall app.
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SendSharedMsg sharedMsg ->
            SendSharedMsg sharedMsg

        Supabase request ->
            Supabase request

        Save data ->
            Save data


{-| Elm Land depends on this function to perform your effects.
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , batch : List msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg sharedMsg ->
            Task.succeed sharedMsg
                |> Task.perform options.fromSharedMsg

        Save { key, value } ->
            outgoing
                { tag = "SAVE"
                , data =
                    Json.Encode.object
                        [ ( "key", Json.Encode.string key )
                        , ( "value", value )
                        ]
                }

        Supabase request ->
            let
                userToken : Maybe String
                userToken =
                    case options.shared.user of
                        Auth.User.NotSignedIn ->
                            Nothing

                        Auth.User.FetchingUserDetails oAuthResponse ->
                            Just oAuthResponse.accessToken

                        Auth.User.SignedIn user ->
                            Just user.supabaseToken

                context : Supabase.Context.Context
                context =
                    Supabase.Context.create
                        { apiKey = options.shared.supabase.apiKey
                        , url = options.shared.supabase.url
                        }
                        |> withUserToken

                withUserToken :
                    Supabase.Context.Context
                    -> Supabase.Context.Context
                withUserToken context_ =
                    case userToken of
                        Just token ->
                            context_
                                |> Supabase.Context.withUserToken token

                        Nothing ->
                            context_
            in
            case request of
                FetchSupabaseUser ->
                    Supabase.Auth.getUserData
                        { onResponse =
                            Shared.Msg.SupabaseUserApiResponded
                                >> options.fromSharedMsg
                        }
                        context


port outgoing :
    { tag : String
    , data : Json.Encode.Value
    }
    -> Cmd msg
