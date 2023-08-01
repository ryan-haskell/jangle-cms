module Stories.IconButton exposing (main)

import Components.Icon exposing (Icon)
import Components.IconButton
import Html exposing (Html)
import Json.Decode
import Stories.Icon
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { icon : Maybe Icon
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "icon"
            , options = Stories.Icon.iconOptions
            }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.simple
        { controls = decoder
        , view = view
        }


type Msg
    = NothingHappened



-- VIEW


view : Controls -> Html Msg
view controls =
    let
        icon : Icon
        icon =
            controls.icon
                |> Maybe.withDefault Components.Icon.GitHub
    in
    Components.IconButton.new
        { label = "Click me"
        , icon = icon
        }
        |> Components.IconButton.view
