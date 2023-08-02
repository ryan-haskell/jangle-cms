module Stories.Input exposing (main)

import Components.Input
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { withStyle : Maybe (Components.Input.Input Msg -> Components.Input.Input Msg)
    , hasError : Bool
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "style"
            , options =
                [ ( "Text"
                  , identity
                  )
                , ( "Search"
                  , Components.Input.withStyleSearch
                  )
                , ( "Multiline"
                  , Components.Input.withStyleMultiline
                  )
                ]
            }
        |> Storybook.Controls.withBoolean { id = "error" }


main : Storybook.Component.Component Controls Model Msg
main =
    Storybook.Component.sandbox
        { controls = decoder
        , init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    { value : String }


init : Controls -> Model
init controls =
    { value = ""
    }



-- UPDATE


type Msg
    = ChangedInput String


update : Controls -> Msg -> Model -> Model
update controls msg model =
    case msg of
        ChangedInput text ->
            { model | value = text }



-- VIEW


view : Controls -> Model -> Html Msg
view controls model =
    Components.Input.new { value = model.value }
        |> Maybe.withDefault identity controls.withStyle
        |> Components.Input.withError controls.hasError
        |> Components.Input.withOnInput ChangedInput
        |> Components.Input.view
