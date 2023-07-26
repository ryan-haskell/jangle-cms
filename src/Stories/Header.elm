module Stories.Header exposing (main)

import Components.Header
import Html exposing (Html)
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { title : String
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withText { id = "title" }


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
    Components.Header.view
        { title = controls.title
        }
