module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Auth.User
import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Flags
import Shared.Model
import Shared.Msg
import Supabase.OAuthResponse



-- FLAGS


type alias Flags =
    Shared.Flags.Flags


decoder : Json.Decode.Decoder Flags
decoder =
    Shared.Flags.decoder



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags : Flags
        flags =
            flagsResult
                |> Result.withDefault
                    { supabase = { url = "???", apiKey = "???" }
                    , oAuthResponse = Nothing
                    }

        lastOAuthResponse : Maybe Supabase.OAuthResponse.OAuthResponse
        lastOAuthResponse =
            List.filterMap identity
                [ Supabase.OAuthResponse.fromUrlFragment route.hash
                , flags.oAuthResponse
                ]
                |> List.head
    in
    case lastOAuthResponse of
        Just oAuthResponse ->
            ( { supabase = flags.supabase
              , user = Auth.User.FetchingUserDetails oAuthResponse
              }
            , Effect.batch
                [ Effect.fetchSupabaseUser
                , Effect.saveOAuthResponse oAuthResponse
                , Effect.replaceRoute
                    { path = route.path
                    , query = route.query
                    , hash = Nothing
                    }
                ]
            )

        Nothing ->
            ( { supabase = flags.supabase
              , user = Auth.User.NotSignedIn
              }
            , Effect.none
            )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.SupabaseUserApiResponded (Err httpError) ->
            ( model
            , Effect.none
              -- |> Debug.log "TODO: Report this error to Sentry"
            )

        Shared.Msg.SupabaseUserApiResponded (Ok user) ->
            let
                toUser :
                    { response
                        | supabaseToken : String
                        , githubToken : Maybe String
                    }
                    -> Auth.User.User
                toUser response =
                    { id = user.id
                    , name =
                        [ user.github
                            |> Maybe.andThen .name
                        , user.github
                            |> Maybe.map .username
                        ]
                            |> List.filterMap identity
                            |> List.head
                            |> Maybe.withDefault user.email
                    , email = user.email
                    , image = user.github |> Maybe.andThen .avatar_url
                    , supabaseToken = response.supabaseToken
                    , githubToken = response.githubToken
                    , githubUsername =
                        user.github
                            |> Maybe.map .username
                    }
            in
            case model.user of
                Auth.User.NotSignedIn ->
                    ( model, Effect.none )

                Auth.User.FetchingUserDetails oAuthResponse ->
                    ( { model
                        | user =
                            Auth.User.SignedIn
                                (toUser
                                    { supabaseToken = oAuthResponse.accessToken
                                    , githubToken = Just oAuthResponse.providerToken
                                    }
                                )
                      }
                    , Effect.none
                    )

                Auth.User.SignedIn oldUser ->
                    ( { model
                        | user =
                            Auth.User.SignedIn
                                (toUser
                                    { supabaseToken = oldUser.supabaseToken
                                    , githubToken = oldUser.githubToken
                                    }
                                )
                      }
                    , Effect.none
                    )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
