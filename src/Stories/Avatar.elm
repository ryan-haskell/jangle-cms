module Stories.Avatar exposing (main)

import Components.Avatar
import Components.Icon
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { name : String
    , project : String
    , hasImage : Bool
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withText { id = "name" }
        |> Storybook.Controls.withText { id = "project" }
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
        { name = controls.name
        , project = controls.project
        , image =
            if controls.hasImage then
                Just "https://avatars.githubusercontent.com/u/6187256?v=4"

            else
                Nothing
        }
