port module Storybook.Component exposing
    ( Component, new
    , sandbox, element
    )

{-|

@docs Component, new
@docs sandbox, element

-}

import Browser
import Html exposing (Html)
import Json.Decode
import Storybook.Controls


port log : String -> Cmd msg


type alias Component controls model msg =
    Platform.Program
        Json.Decode.Value
        (Model controls model)
        msg


type Model controls model
    = Success { controls : controls, model : model }
    | Failure


new :
    { controls : Storybook.Controls.Decoder controls
    , view : controls -> Html msg
    }
    -> Component controls () msg
new options =
    Browser.element
        { init =
            init
                { controls = options.controls
                , init = \controls -> ( (), Cmd.none )
                }
        , update =
            update
                { update = \controls msg model -> ( model, Cmd.none )
                }
        , view = view { view = \controls model -> options.view controls }
        , subscriptions = \_ -> Sub.none
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
                , init = \controls -> ( options.init controls, Cmd.none )
                }
        , update =
            update
                { update = \controls msg model -> ( options.update controls msg model, Cmd.none )
                }
        , view = view options
        , subscriptions = \_ -> Sub.none
        }


element :
    { controls : Storybook.Controls.Decoder controls
    , init : controls -> ( model, Cmd msg )
    , update : controls -> msg -> model -> ( model, Cmd msg )
    , view : controls -> model -> Html msg
    , subscriptions : controls -> model -> Sub msg
    }
    -> Component controls model msg
element options =
    Browser.element
        { init = init options
        , update = update options
        , view = view options
        , subscriptions = subscriptions options
        }


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
                }
            , cmd
            )

        Nothing ->
            ( Failure, Cmd.none )


update :
    { options
        | update : controls -> msg -> model -> ( model, Cmd msg )
    }
    -> msg
    -> Model controls model
    -> ( Model controls model, Cmd msg )
update options msg model_ =
    case model_ of
        Failure ->
            ( Failure, Cmd.none )

        Success { controls, model } ->
            let
                ( model2, cmd ) =
                    options.update controls msg model
                        |> Tuple.mapFirst (\newModel -> Success { controls = controls, model = newModel })
            in
            ( model2
            , Cmd.batch
                [ cmd
                , log (Debug.toString msg)
                ]
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
