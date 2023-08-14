module Stories.Checkbox exposing (main)

import Components.Checkbox
import Css
import Html exposing (..)
import Http
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    {}


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls


main : Storybook.Component.Component Controls Model Msg
main =
    Storybook.Component.sandbox
        { controls = decoder
        , init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { isChecked : Bool
    }


init : Controls -> Model
init _ =
    { isChecked = False
    }



-- UPDATE


type Msg
    = ToggledCheckbox Bool


update : Controls -> Msg -> Model -> Model
update _ msg model =
    case msg of
        ToggledCheckbox isChecked ->
            { model | isChecked = isChecked }



-- VIEW


view : Controls -> Model -> Html Msg
view controls model =
    div [ Css.col, Css.gap_16 ]
        [ Components.Checkbox.view
            { label = "Is this field required?"
            , onCheck = ToggledCheckbox
            , isChecked = model.isChecked
            }
        ]
