module Stories.SidebarLink exposing (main)

import Components.Icon exposing (Icon)
import Components.SidebarLink
import Html exposing (Html)
import Stories.Icon
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { label : String
    , icon : Maybe Icon
    , state : Maybe State
    }


type State
    = Default
    | Selected


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withText
            { id = "label"
            }
        |> Storybook.Controls.withSelect
            { id = "icon"
            , options = Stories.Icon.iconOptions
            }
        |> Storybook.Controls.withSelect
            { id = "state"
            , options =
                [ ( "Default", Default )
                , ( "Selected", Selected )
                ]
            }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.simple
        { controls = decoder
        , view = view
        }


type Msg
    = NoOp



-- VIEW


view : Controls -> Html Msg
view controls =
    Components.SidebarLink.new
        { label = controls.label
        , icon =
            controls.icon
                |> Maybe.withDefault Components.Icon.Page
        }
        |> Components.SidebarLink.withSelectedStyle
            (controls.state == Just Selected)
        |> Components.SidebarLink.view
