module Stories.List exposing (main)

import Components.Icon
import Components.List
import Components.ListItem
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    {}


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.simple
        { controls = decoder
        , view = view
        }


type Msg
    = Clicked String



-- VIEW


view : Controls -> Html Msg
view controls =
    Components.List.view
        { items =
            List.repeat 5
                (Components.ListItem.new
                    { icon = Components.Icon.GitHub
                    , label = "@ryannhg/rhg_dev"
                    }
                    |> Components.ListItem.withOnClick (Clicked "@ryannhg/rhg_dev")
                )
        }
