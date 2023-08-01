module Stories.SidebarLinkGroup exposing (main)

import Components.Icon exposing (Icon)
import Components.SidebarLink
import Components.SidebarLinkGroup
import Html exposing (Html)
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { label : String
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withText
            { id = "label"
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
    Components.SidebarLinkGroup.view
        { title = controls.label
        , links =
            [ Components.SidebarLink.new
                { icon = Components.Icon.Page
                , label = "Homepage"
                }
            , Components.SidebarLink.new
                { icon = Components.Icon.Edit
                , label = "Blog posts"
                }
                |> Components.SidebarLink.withSelectedStyle True
            , Components.SidebarLink.new
                { icon = Components.Icon.Page
                , label = "Contact page"
                }
            ]
        }
