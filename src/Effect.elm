port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , map, toCmd
    , saveOAuthResponse, clearOAuthResponse
    , fetchSupabaseUser
    , showDialog
    , signOut
    , sendGitHubGraphQL
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs map, toCmd


## Custom effects

@docs saveOAuthResponse, clearOAuthResponse
@docs fetchSupabaseUser
@docs showDialog

@docs signOut

@docs sendGitHubGraphQL

-}

import Auth.User
import Browser.Navigation
import Dict exposing (Dict)
import GitHub.Operation
import GraphQL.Decode
import GraphQL.Encode
import GraphQL.Http
import Http
import Json.Decode
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
      -- DIALOGS
    | ShowDialog { id : String }
      -- GRAPHQL CALLS
    | SendGitHubGraphQL (Operation msg)



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


clearOAuthResponse : Effect msg
clearOAuthResponse =
    Save
        { key = "oAuthResponse"
        , value = Json.Encode.null
        }



-- SUPABASE


type SupabaseRequest
    = FetchSupabaseUser


fetchSupabaseUser : Effect msg
fetchSupabaseUser =
    Supabase FetchSupabaseUser


signOut : Effect msg
signOut =
    SendSharedMsg Shared.Msg.SignOut



-- DIALOGS


showDialog : { id : String } -> Effect msg
showDialog { id } =
    ShowDialog { id = id }



-- GITHUB GRAPHQL


sendGitHubGraphQL :
    { operation : GitHub.Operation.Operation value
    , onResponse : Result Http.Error value -> msg
    }
    -> Effect msg
sendGitHubGraphQL ({ operation } as options) =
    SendGitHubGraphQL
        { name = operation.name
        , query = operation.query
        , variables = operation.variables
        , decoder =
            operation.decoder
                |> mapGraphQLDecoder (\value -> options.onResponse (Ok value))
        , onHttpError = Err >> options.onResponse
        }



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

        ShowDialog data ->
            ShowDialog data

        SendGitHubGraphQL operation ->
            SendGitHubGraphQL (mapOperation fn operation)


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
                        { apiKey = options.shared.flags.supabase.apiKey
                        , url = options.shared.flags.supabase.url
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

        ShowDialog { id } ->
            outgoing
                { tag = "SHOW_DIALOG"
                , data =
                    Json.Encode.object
                        [ ( "id", Json.Encode.string id )
                        ]
                }

        SendGitHubGraphQL operation ->
            let
                sendHttpRequest : { token : String } -> Cmd msg
                sendHttpRequest user =
                    Http.request
                        { method = "POST"
                        , headers =
                            [ Http.header
                                "Authorization"
                                ("Bearer " ++ user.token)
                            ]
                        , url = "https://api.github.com/graphql"
                        , body =
                            GraphQL.Http.body
                                { operationName = Just operation.name
                                , query = operation.query
                                , variables = operation.variables
                                }
                        , expect =
                            GraphQL.Http.expect
                                (\result ->
                                    case result of
                                        Ok msg ->
                                            msg

                                        Err httpError ->
                                            operation.onHttpError httpError
                                )
                                operation.decoder
                        , timeout = Nothing
                        , tracker = Nothing
                        }
            in
            case options.shared.user of
                Auth.User.NotSignedIn ->
                    Route.Path.SignIn
                        |> Route.Path.toString
                        |> Browser.Navigation.pushUrl options.key

                Auth.User.FetchingUserDetails response ->
                    sendHttpRequest { token = response.providerToken }

                Auth.User.SignedIn user ->
                    sendHttpRequest { token = user.githubToken |> Maybe.withDefault "TODO" }



-- PORTS


port outgoing :
    { tag : String
    , data : Json.Encode.Value
    }
    -> Cmd msg



-- GRAPHQL THINGS


type alias Operation msg =
    { name : String
    , query : String
    , variables : List ( String, GraphQL.Encode.Value )
    , decoder : GraphQL.Decode.Decoder msg
    , onHttpError : Http.Error -> msg
    }


mapOperation : (msg1 -> msg2) -> Operation msg1 -> Operation msg2
mapOperation fn operation =
    { name = operation.name
    , query = operation.query
    , variables = operation.variables
    , decoder = mapGraphQLDecoder fn operation.decoder
    , onHttpError = fn << operation.onHttpError
    }


mapGraphQLDecoder :
    (msg1 -> msg2)
    -> GraphQL.Decode.Decoder msg1
    -> GraphQL.Decode.Decoder msg2
mapGraphQLDecoder fn decoder =
    -- NOTE TO SELF: Expose `GraphQL.Decode.map` like a normal person.
    decoder
        |> GraphQL.Decode.toJsonDecoder
        |> Json.Decode.map fn
        |> GraphQL.Decode.scalar
