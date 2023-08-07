port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , map, toCmd
    , sendDelayedMsg
    , signIn, signOut
    , saveOAuthResponse, clearOAuthResponse
    , showDialog
    , sendHttpErrorToSentry, sendJsonErrorToSentry, sendCustomErrorToSentry
    , sendGitHubGraphQL
    , sendSupabaseGraphQL
    , sendHttpRequest
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs map, toCmd


## Custom effects

@docs sendDelayedMsg

@docs signIn, signOut
@docs saveOAuthResponse, clearOAuthResponse

@docs showDialog

@docs sendHttpErrorToSentry, sendJsonErrorToSentry, sendCustomErrorToSentry

@docs sendGitHubGraphQL
@docs sendSupabaseGraphQL

@docs sendHttpRequest

-}

import Auth.User
import Browser.Navigation
import Dict exposing (Dict)
import GraphQL.Decode
import GraphQL.Encode
import GraphQL.Http
import GraphQL.Operation
import Http
import Json.Decode
import Json.Encode
import Process
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg
import Supabase.Auth
import Supabase.Context
import Supabase.OAuthResponse
import Supabase.Request
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
      -- HTTP
    | SendHttpRequest (HttpRequest msg)
      -- SUPABASE
    | Supabase SupabaseRequest
    | SendSupabaseGraphQL (Operation msg)
      -- DIALOGS
    | ShowDialog { id : String }
      -- GITHUB GRAPHQL
    | SendGitHubGraphQL (Operation msg)
      -- SENTRY ERROR REPORTING
    | SendHttpErrorToSentry
        { method : String
        , url : String
        , response : Maybe String
        , error : Http.Error
        }
    | SendJsonErrorToSentry
        { method : String
        , url : String
        , response : String
        , error : Json.Decode.Error
        }
    | SendCustomErrorToSentry
        { message : String
        , details : List ( String, Json.Encode.Value )
        }


type alias HttpRequest msg =
    { method : String
    , url : String
    , headers : List Http.Header
    , body : Http.Body
    , timeout : Maybe Float
    , tracker : Maybe String
    , decoder : Json.Decode.Decoder msg
    , onHttpError : Http.Error -> msg
    }


fromSupabaseRequest : Supabase.Request.Request value msg -> HttpRequest msg
fromSupabaseRequest request =
    let
        onSuccess : value -> msg
        onSuccess value =
            request.onResponse (Ok value)

        onHttpError : Http.Error -> msg
        onHttpError httpError =
            request.onResponse (Err httpError)
    in
    { method = request.method
    , url = request.url
    , headers = request.headers
    , body = request.body
    , timeout = request.timeout
    , tracker = request.tracker
    , decoder = Json.Decode.map onSuccess request.decoder
    , onHttpError = onHttpError
    }



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


sendDelayedMsg : Int -> msg -> Effect msg
sendDelayedMsg delayInMs msg =
    Process.sleep (Basics.toFloat delayInMs)
        |> Task.map (\_ -> msg)
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



-- HTTP


{-| Send an HTTP get request, with error reporting built-in!
-}
sendHttpRequest :
    { method : String
    , url : String
    , headers : List Http.Header
    , body : Http.Body
    , timeout : Maybe Float
    , tracker : Maybe String
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
    -> Effect msg
sendHttpRequest options =
    let
        onSuccess : value -> msg
        onSuccess value =
            options.onResponse (Ok value)

        onHttpError : Http.Error -> msg
        onHttpError httpError =
            options.onResponse (Err httpError)
    in
    SendHttpRequest
        { method = options.method
        , url = options.url
        , headers = options.headers
        , body = options.body
        , timeout = options.timeout
        , tracker = options.tracker
        , decoder = Json.Decode.map onSuccess options.decoder
        , onHttpError = onHttpError
        }



-- SUPABASE


type SupabaseRequest
    = SignIn


signIn : Effect msg
signIn =
    Supabase SignIn


signOut : Effect msg
signOut =
    SendSharedMsg Shared.Msg.SignOut



-- DIALOGS


showDialog : { id : String } -> Effect msg
showDialog { id } =
    ShowDialog { id = id }



-- GRAPHQL


sendGitHubGraphQL :
    { operation : GraphQL.Operation.Operation value
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


sendSupabaseGraphQL :
    { operation : GraphQL.Operation.Operation value
    , onResponse : Result Http.Error value -> msg
    }
    -> Effect msg
sendSupabaseGraphQL ({ operation } as options) =
    SendSupabaseGraphQL
        { name = operation.name
        , query = operation.query
        , variables = operation.variables
        , decoder =
            operation.decoder
                |> mapGraphQLDecoder (\value -> options.onResponse (Ok value))
        , onHttpError = Err >> options.onResponse
        }



-- SENTRY


sendHttpErrorToSentry :
    { method : String
    , url : String
    , response : Maybe String
    , error : Http.Error
    }
    -> Effect msg
sendHttpErrorToSentry data =
    SendHttpErrorToSentry data


sendJsonErrorToSentry :
    { method : String
    , url : String
    , response : String
    , error : Json.Decode.Error
    }
    -> Effect msg
sendJsonErrorToSentry data =
    SendJsonErrorToSentry data


sendCustomErrorToSentry :
    { message : String
    , details : List ( String, Json.Encode.Value )
    }
    -> Effect msg
sendCustomErrorToSentry data =
    SendCustomErrorToSentry data



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

        SendSupabaseGraphQL operation ->
            SendSupabaseGraphQL (mapOperation fn operation)

        SendHttpRequest data ->
            SendHttpRequest
                { method = data.method
                , url = data.url
                , headers = data.headers
                , body = data.body
                , timeout = data.timeout
                , tracker = data.tracker
                , onHttpError = \httpError -> fn (data.onHttpError httpError)
                , decoder = Json.Decode.map fn data.decoder
                }

        SendHttpErrorToSentry data ->
            SendHttpErrorToSentry data

        SendJsonErrorToSentry data ->
            SendJsonErrorToSentry data

        SendCustomErrorToSentry data ->
            SendCustomErrorToSentry data


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

                httpRequest : HttpRequest msg
                httpRequest =
                    case request of
                        SignIn ->
                            Supabase.Auth.getUserData
                                { onResponse =
                                    Shared.Msg.SupabaseUserApiResponded
                                        >> options.fromSharedMsg
                                }
                                context
                                |> fromSupabaseRequest
            in
            sendHttpWithErrorReporting
                options
                httpRequest

        ShowDialog { id } ->
            outgoing
                { tag = "SHOW_DIALOG"
                , data =
                    Json.Encode.object
                        [ ( "id", Json.Encode.string id )
                        ]
                }

        SendSupabaseGraphQL operation ->
            let
                sendSupabaseGraphQLHttpRequest : { token : String } -> Cmd msg
                sendSupabaseGraphQLHttpRequest user =
                    sendHttpWithErrorReporting options
                        { method = "POST"
                        , headers =
                            [ Http.header "apikey" options.shared.flags.supabase.apiKey
                            , Http.header
                                "Authorization"
                                ("Bearer " ++ user.token)
                            ]
                        , url = options.shared.flags.supabase.url ++ "/graphql/v1"
                        , body =
                            GraphQL.Http.body
                                { operationName = Just operation.name
                                , query = operation.query
                                , variables = operation.variables
                                }
                        , onHttpError = operation.onHttpError
                        , decoder =
                            Json.Decode.field "data"
                                (GraphQL.Decode.toJsonDecoder operation.decoder)
                        , timeout = Just 15000
                        , tracker = Nothing
                        }
            in
            case options.shared.user of
                Auth.User.NotSignedIn ->
                    Route.Path.SignIn
                        |> Route.Path.toString
                        |> Browser.Navigation.pushUrl options.key

                Auth.User.FetchingUserDetails response ->
                    sendSupabaseGraphQLHttpRequest
                        { token = response.accessToken
                        }

                Auth.User.SignedIn user ->
                    sendSupabaseGraphQLHttpRequest
                        { token = user.supabaseToken
                        }

        SendGitHubGraphQL operation ->
            let
                sendGitHubGraphQLHttpRequest : { token : String } -> Cmd msg
                sendGitHubGraphQLHttpRequest user =
                    sendHttpWithErrorReporting options
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
                        , onHttpError = operation.onHttpError
                        , decoder =
                            Json.Decode.field "data"
                                (GraphQL.Decode.toJsonDecoder operation.decoder)
                        , timeout = Just 15000
                        , tracker = Nothing
                        }
            in
            case options.shared.user of
                Auth.User.NotSignedIn ->
                    Route.Path.SignIn
                        |> Route.Path.toString
                        |> Browser.Navigation.pushUrl options.key

                Auth.User.FetchingUserDetails response ->
                    sendGitHubGraphQLHttpRequest
                        { token = response.providerToken
                        }

                Auth.User.SignedIn user ->
                    case user.github of
                        Just githubInfo ->
                            sendGitHubGraphQLHttpRequest
                                { token = githubInfo.token
                                }

                        Nothing ->
                            reportCustomErrorToSentry options
                                { message = "Attempted to call GitHub GraphQL API without token"
                                , details = []
                                }

        SendHttpErrorToSentry data ->
            outgoing
                { tag = "SENTRY_REPORT_HTTP_ERROR"
                , data =
                    Json.Encode.object
                        [ ( "method", Json.Encode.string data.method )
                        , ( "url", Json.Encode.string data.url )
                        , ( "response"
                          , case data.response of
                                Just response ->
                                    Json.Encode.string response

                                Nothing ->
                                    Json.Encode.null
                          )
                        , ( "error", Json.Encode.string (fromHttpErrorToString data.error) )
                        , ( "user"
                          , case options.shared.user of
                                Auth.User.SignedIn user ->
                                    Auth.User.encode user

                                _ ->
                                    Json.Encode.null
                          )
                        ]
                }

        SendJsonErrorToSentry data ->
            outgoing
                { tag = "SENTRY_REPORT_JSON_ERROR"
                , data =
                    Json.Encode.object
                        [ ( "method", Json.Encode.string data.method )
                        , ( "url", Json.Encode.string data.url )
                        , ( "response", Json.Encode.string data.response )
                        , ( "title", Json.Encode.string (fromJsonErrorToTitle data.error) )
                        , ( "error", Json.Encode.string (Json.Decode.errorToString data.error) )
                        , ( "user"
                          , case options.shared.user of
                                Auth.User.SignedIn user ->
                                    Auth.User.encode user

                                _ ->
                                    Json.Encode.null
                          )
                        ]
                }

        SendCustomErrorToSentry data ->
            reportCustomErrorToSentry options data

        SendHttpRequest data ->
            sendHttpWithErrorReporting options data



-- AUTOMATIC ERROR REPORTING


reportCustomErrorToSentry :
    { options | shared : Shared.Model.Model }
    ->
        { message : String
        , details : List ( String, Json.Encode.Value )
        }
    -> Cmd msg
reportCustomErrorToSentry options data =
    outgoing
        { tag = "SENTRY_REPORT_CUSTOM_ERROR"
        , data =
            Json.Encode.object
                [ ( "message", Json.Encode.string data.message )
                , ( "details", Json.Encode.object data.details )
                , ( "user"
                  , case options.shared.user of
                        Auth.User.SignedIn user ->
                            Auth.User.encode user

                        _ ->
                            Json.Encode.null
                  )
                ]
        }


sendHttpWithErrorReporting :
    { options
        | fromSharedMsg : Shared.Msg.Msg -> msg
        , batch : List msg -> msg
    }
    -> HttpRequest msg
    -> Cmd msg
sendHttpWithErrorReporting options request =
    let
        toMsg : Result CustomError msg -> msg
        toMsg =
            fromCustomResultToMsg
                { method = request.method
                , url = request.url
                , fromSharedMsg = options.fromSharedMsg
                , batch = options.batch
                , onHttpError = request.onHttpError
                }

        fromHttpResponse : Http.Response String -> Result CustomError msg
        fromHttpResponse =
            fromHttpResponseToCustomResult
                { decoder = request.decoder
                }
    in
    Http.request
        { method = request.method
        , url = request.url
        , headers = request.headers
        , body = request.body
        , timeout = request.timeout
        , tracker = request.tracker
        , expect = Http.expectStringResponse toMsg fromHttpResponse
        }


{-| Because we want to send Sentry the actual JSON response,
`Http.Error` won't be enough.

For that reason, we make our own `CustomError` type that can store
more data about the HTTP request.

-}
type CustomError
    = JsonDecodeError
        { response : String
        , reason : Json.Decode.Error
        }
    | HttpError
        { response : Maybe String
        , reason : Http.Error
        }


toHttpError : CustomError -> Http.Error
toHttpError customError =
    case customError of
        JsonDecodeError { response, reason } ->
            Http.BadBody (Json.Decode.errorToString reason)

        HttpError { reason } ->
            reason


fromHttpErrorToString : Http.Error -> String
fromHttpErrorToString httpError =
    case httpError of
        Http.BadBody _ ->
            "BadBody"

        Http.BadUrl url ->
            "BadUrl: " ++ url

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus code ->
            "Status " ++ String.fromInt code


fromCustomResultToMsg :
    { method : String
    , url : String
    , batch : List msg -> msg
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , onHttpError : Http.Error -> msg
    }
    -> Result CustomError msg
    -> msg
fromCustomResultToMsg options result =
    case result of
        Ok msg ->
            msg

        Err customError ->
            options.batch
                [ -- Let the original page handle the error
                  customError
                    |> toHttpError
                    |> options.onHttpError
                , -- Report the error to Sentry
                  case customError of
                    JsonDecodeError { response, reason } ->
                        Shared.Msg.SendJsonDecodeErrorToSentry
                            { method = options.method
                            , url = options.url
                            , response = response
                            , error = reason
                            }
                            |> options.fromSharedMsg

                    HttpError { response, reason } ->
                        Shared.Msg.SendHttpErrorToSentry
                            { method = options.method
                            , url = options.url
                            , response = response
                            , error = reason
                            }
                            |> options.fromSharedMsg
                ]


fromJsonErrorToTitle : Json.Decode.Error -> String
fromJsonErrorToTitle error =
    let
        toInfo : Json.Decode.Error -> List String -> { path : List String, problem : String }
        toInfo err path =
            case err of
                Json.Decode.Field name inner ->
                    toInfo inner (path ++ [ name ])

                Json.Decode.Index name inner ->
                    toInfo inner path

                Json.Decode.OneOf [] ->
                    { path = path, problem = "Empty OneOf provided" }

                Json.Decode.OneOf (first :: _) ->
                    toInfo first path

                Json.Decode.Failure problem value ->
                    { path = path, problem = problem }

        info : { path : List String, problem : String }
        info =
            toInfo error []
    in
    if List.isEmpty info.path then
        info.problem

    else
        "Problem at ${path}: ${problem}"
            |> String.replace "${path}" (String.join "." info.path)
            |> String.replace "${problem}" info.problem


fromHttpResponseToCustomResult :
    { decoder : Json.Decode.Decoder msg }
    -> Http.Response String
    -> Result CustomError msg
fromHttpResponseToCustomResult options httpResponse =
    case httpResponse of
        Http.BadUrl_ url_ ->
            -- means you did not provide a valid URL.
            Err
                (HttpError
                    { response = Nothing
                    , reason = Http.BadUrl url_
                    }
                )

        Http.Timeout_ ->
            -- means it took too long to get a response.
            Err
                (HttpError
                    { response = Nothing
                    , reason = Http.Timeout
                    }
                )

        Http.NetworkError_ ->
            -- means the user turned off their wifi, went in a cave, etc.
            Err
                (HttpError
                    { response = Nothing
                    , reason = Http.NetworkError
                    }
                )

        Http.BadStatus_ metadata response ->
            -- means you got a response back, but the status code indicates failure.
            Err
                (HttpError
                    { response = Just response
                    , reason = Http.BadStatus metadata.statusCode
                    }
                )

        Http.GoodStatus_ metadata response ->
            -- means you got a response back with a nice status code!
            case Json.Decode.decodeString options.decoder response of
                Ok msg ->
                    Ok msg

                Err jsonDecodeError ->
                    Err
                        (JsonDecodeError
                            { response = response
                            , reason = jsonDecodeError
                            }
                        )



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
