module Stories.Avatar exposing (main)

import Components.Avatar
import Components.Icon
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { label : String
    , sublabel : String
    , hasImage : Bool
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withText { id = "label" }
        |> Storybook.Controls.withText { id = "sublabel" }
        |> Storybook.Controls.withBoolean { id = "image" }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.new
        { controls = decoder
        , view = view
        }


type Msg
    = NoOp



-- VIEW


view : Controls -> Html Msg
view controls =
    Components.Avatar.view
        { label = controls.label
        , sublabel = controls.sublabel
        , image =
            if controls.hasImage then
                Just "https://avatars.githubusercontent.com/u/6187256?v=4"

            else
                Nothing
        }
