port module Storybook.Component exposing
    ( Component, simple
    , sandbox
    , new
    )

{-|

@docs Component, simple
@docs sandbox
@docs new

-}

import Browser
import Browser.Navigation
import Effect exposing (Effect)
import Html exposing (Html)
import Json.Decode
import Route
import Shared
import Storybook.Controls
import Task
import Url


port logMsg : String -> Cmd msg


port logUrl : String -> Cmd msg


type alias Component controls model msg =
    Platform.Program
        Json.Decode.Value
        (Model controls model)
        (Msg msg)


type Model controls model
    = Success
        { controls : controls
        , model : model
        , app : Maybe App
        }
    | Failure


type alias App =
    { shared : Shared.Model
    , key : Browser.Navigation.Key
    , url : Url.Url
    }


type Msg msg
    = Sent msg
    | UrlChanged Url.Url
    | UrlRequested Browser.UrlRequest
    | Shared Shared.Msg
    | Batch (List (Msg msg))


simple :
    { controls : Storybook.Controls.Decoder controls
    , view : controls -> Html msg
    }
    -> Component controls () msg
simple options =
    new
        { controls = options.controls
        , init = \_ -> ( (), Effect.none )
        , update = \_ _ model -> ( model, Effect.none )
        , view = \controls _ -> options.view controls
        , subscriptions = \_ _ -> Sub.none
        }


sandbox :
    { controls : Storybook.Controls.Decoder controls
    , init : controls -> model
    , update : controls -> msg -> model -> model
    , view : controls -> model -> Html msg
    }
    -> Component controls model msg
sandbox options =
    Browser.element
        { init =
            init
                { controls = options.controls
                , init =
                    \controls ->
                        ( options.init controls
                        , Cmd.none
                        )
                }
        , update =
            update
                { update =
                    \controls msg model ->
                        ( options.update controls msg model
                        , Cmd.none
                        )
                }
        , view =
            view
                { view = \controls model -> options.view controls model |> Html.map Sent
                }
        , subscriptions = \_ -> Sub.none
        }


new :
    { controls : Storybook.Controls.Decoder controls
    , init : controls -> ( model, Effect msg )
    , update : controls -> msg -> model -> ( model, Effect msg )
    , view : controls -> model -> Html msg
    , subscriptions : controls -> model -> Sub msg
    }
    -> Component controls model msg
new options =
    Browser.application
        { onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        , init =
            \flags url key ->
                case Storybook.Controls.decodeValue flags options.controls of
                    Just controls ->
                        let
                            ( shared, sharedEffect ) =
                                Shared.init
                                    (Json.Decode.decodeValue Shared.decoder flags)
                                    (Route.fromUrl () url)

                            app : App
                            app =
                                { key = key
                                , url = url
                                , shared = shared
                                }

                            ( model, componentEffect ) =
                                options.init controls
                        in
                        ( Success
                            { controls = controls
                            , model = model
                            , app = Just app
                            }
                        , toCmd app componentEffect
                        )

                    Nothing ->
                        ( Failure, Cmd.none )
        , update =
            \msg_ model_ ->
                case msg_ of
                    Sent msg ->
                        case model_ of
                            Success ({ controls, model } as success) ->
                                let
                                    ( newModel, effect ) =
                                        options.update controls msg model

                                    cmd : Cmd (Msg msg)
                                    cmd =
                                        case success.app of
                                            Just app ->
                                                toCmd app effect

                                            Nothing ->
                                                Cmd.none
                                in
                                ( Success { success | model = newModel }
                                , Cmd.batch
                                    [ cmd
                                    , logMsg (Debug.toString msg)
                                    ]
                                )

                            _ ->
                                ( model_
                                , Cmd.none
                                )

                    Shared _ ->
                        ( model_, logMsg (Debug.toString msg_) )

                    Batch _ ->
                        ( model_, logMsg (Debug.toString msg_) )

                    UrlChanged url ->
                        ( model_, logUrl url.path )

                    UrlRequested (Browser.Internal url) ->
                        ( model_, logUrl url.path )

                    UrlRequested (Browser.External url) ->
                        ( model_, logUrl url )
        , view =
            view
                { view = \controls model -> options.view controls model |> Html.map Sent
                }
                >> (\html -> { title = "Storybook", body = [ html ] })
        , subscriptions = subscriptions options >> Sub.map Sent
        }


toCmd : App -> Effect msg -> Cmd (Msg msg)
toCmd app effect =
    Effect.toCmd
        { key = app.key
        , url = app.url
        , shared = app.shared
        , fromSharedMsg = Shared
        , batch = Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map Sent effect)


type alias Options controls model msg =
    { controls : Storybook.Controls.Decoder controls
    , init : controls -> ( model, Cmd msg )
    , update : controls -> msg -> model -> ( model, Cmd msg )
    , view : controls -> model -> Html msg
    , subscriptions : controls -> model -> Sub msg
    }


init :
    { options
        | controls : Storybook.Controls.Decoder controls
        , init : controls -> ( model, Cmd msg )
    }
    -> Json.Decode.Value
    -> ( Model controls model, Cmd msg )
init options flags =
    case Storybook.Controls.decodeValue flags options.controls of
        Just controls ->
            let
                ( model, cmd ) =
                    options.init controls
            in
            ( Success
                { controls = controls
                , model = model
                , app = Nothing
                }
            , cmd
            )

        Nothing ->
            ( Failure, Cmd.none )


update :
    { options
        | update : controls -> msg -> model -> ( model, Cmd msg )
    }
    -> Msg msg
    -> Model controls model
    -> ( Model controls model, Cmd (Msg msg) )
update options msg_ model_ =
    case model_ of
        Failure ->
            ( Failure, Cmd.none )

        Success ({ controls, model } as success) ->
            case msg_ of
                Sent msg ->
                    let
                        ( model2, cmd ) =
                            options.update controls msg model
                                |> Tuple.mapFirst
                                    (\newModel ->
                                        Success { success | model = newModel }
                                    )
                    in
                    ( model2
                    , Cmd.batch
                        [ cmd |> Cmd.map Sent
                        , logMsg (Debug.toString msg)
                        ]
                    )

                _ ->
                    ( model_
                    , logMsg (Debug.toString msg_)
                    )


view :
    { options | view : controls -> model -> Html msg }
    -> Model controls model
    -> Html msg
view options model_ =
    case model_ of
        Failure ->
            Html.text "Please check your Storybook controls"

        Success { controls, model } ->
            options.view controls model


subscriptions :
    { options | subscriptions : controls -> model -> Sub msg }
    -> Model controls model
    -> Sub msg
subscriptions options model_ =
    case model_ of
        Failure ->
            Sub.none

        Success { controls, model } ->
            options.subscriptions controls model
