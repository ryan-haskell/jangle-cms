module Components.SidebarLinkGroup exposing (view)

import Components.SidebarLink exposing (SidebarLink)
import Css
import Html exposing (..)


view :
    { title : String
    , links : List SidebarLink
    }
    -> Html msg
view props =
    div [ Css.col ]
        [ div
            [ Css.padX_16
            , Css.padY_12
            , Css.font_linkGroupLabel
            , Css.color_textSecondary
            , Css.uppercase
            , Css.ellipsis
            ]
            [ text props.title ]
        , div [ Css.col ] (List.map Components.SidebarLink.view props.links)
        ]
