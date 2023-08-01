module Stories.Dialog exposing (main)

import Components.Button
import Components.Dialog
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { variant : Maybe Variant
    }


type Variant
    = CreateAProject


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "variant"
            , options =
                [ ( "CreateAProject", CreateAProject )
                ]
            }


main : Storybook.Component.Component Controls Model Msg
main =
    Storybook.Component.new
        { controls = decoder
        , init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


init : Controls -> ( Model, Effect Msg )
init controls =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ClickedOpenDialog
    | ClosedDialog


update : Controls -> Msg -> Model -> ( Model, Effect Msg )
update controls msg model =
    case msg of
        ClickedOpenDialog ->
            ( model
            , Effect.showDialog { id = dialogId }
            )

        ClosedDialog ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Controls -> Model -> Sub Msg
subscriptions controls model =
    Sub.none



-- VIEW


dialogId : String
dialogId =
    "dialog__create-a-project"


view : Controls -> Model -> Html Msg
view controls model =
    let
        viewCreateAProject : Html Msg
        viewCreateAProject =
            div [ Css.row, Css.h_fill, Css.align_center, Css.gap_8, Css.pad_48 ]
                [ Components.Button.new { label = "Open dialog" }
                    |> Components.Button.withOnClick ClickedOpenDialog
                    |> Components.Button.view
                , Components.Dialog.new
                    { title = "Create a project"
                    , content = []
                    }
                    |> Components.Dialog.withSubtitle "Connect to an existing GitHub repository"
                    |> Components.Dialog.withOnClose ClosedDialog
                    |> Components.Dialog.withId dialogId
                    |> Components.Dialog.view
                ]
    in
    case controls.variant of
        Just CreateAProject ->
            viewCreateAProject

        Nothing ->
            viewCreateAProject
