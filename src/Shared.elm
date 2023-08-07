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
import Supabase.Scalars.UUID



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
                    { baseUrl = "https://app.jangle.io"
                    , supabase = { url = "???", apiKey = "???" }
                    , cachedOAuthResponse = Nothing
                    }

        lastOAuthResponse : Maybe Supabase.OAuthResponse.OAuthResponse
        lastOAuthResponse =
            List.filterMap identity
                [ Supabase.OAuthResponse.fromUrlFragment route.hash
                , flags.cachedOAuthResponse
                ]
                |> List.head
    in
    case lastOAuthResponse of
        Just oAuthResponse ->
            ( { flags = flags
              , user = Auth.User.FetchingUserDetails oAuthResponse
              }
            , Effect.batch
                [ Effect.signIn
                , Effect.saveOAuthResponse oAuthResponse
                , Effect.replaceRoute
                    { path = route.path
                    , query = route.query
                    , hash = Nothing
                    }
                ]
            )

        Nothing ->
            ( { flags = flags
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
        Shared.Msg.SignOut ->
            ( { model | user = Auth.User.NotSignedIn }
            , Effect.clearOAuthResponse
            )

        Shared.Msg.SendHttpErrorToSentry data ->
            ( model
            , Effect.sendHttpErrorToSentry data
            )

        Shared.Msg.SendJsonDecodeErrorToSentry data ->
            ( model
            , Effect.sendJsonErrorToSentry data
            )

        Shared.Msg.SupabaseUserApiResponded (Err httpError) ->
            ( { model | user = Auth.User.NotSignedIn }
            , Effect.clearOAuthResponse
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
                    { id = Supabase.Scalars.UUID.fromString user.id
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
                    , github =
                        Maybe.map2 Auth.User.GitHubInfo
                            response.githubToken
                            (user.github
                                |> Maybe.map .username
                            )
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
                                    , githubToken = oldUser.github |> Maybe.map .token
                                    }
                                )
                      }
                    , Effect.none
                    )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
