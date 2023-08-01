module Stories.UserControls exposing (main)

import Components.Icon
import Components.UserControls
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { name : String
    , email : String
    , hasImage : Bool
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withText { id = "name" }
        |> Storybook.Controls.withText { id = "email" }
        |> Storybook.Controls.withBoolean { id = "image" }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.simple
        { controls = decoder
        , view = view
        }


type Msg
    = ClickedUserControls



-- VIEW


view : Controls -> Html Msg
view controls =
    Components.UserControls.new
        { user =
            { name = controls.name
            , email = controls.email
            , image =
                if controls.hasImage then
                    Just "https://avatars.githubusercontent.com/u/6187256?v=4"

                else
                    Nothing
            }
        }
        |> Components.UserControls.withOnClick ClickedUserControls
        |> Components.UserControls.view
