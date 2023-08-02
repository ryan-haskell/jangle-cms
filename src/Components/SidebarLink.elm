module Components.SidebarLink exposing
    ( SidebarLink, new
    , withSelectedStyle, withRoutePath
    , view
    )

{-|

@docs SidebarLink, new
@docs withSelectedStyle, withRoutePath
@docs view

-}

import Components.Icon exposing (Icon)
import Css
import Html exposing (..)
import Html.Attributes.Extra
import Route.Path exposing (Path)


type SidebarLink
    = SidebarLink
        { label : String
        , icon : Icon
        , path : Maybe Path
        , isSelected : Bool
        }


new :
    { label : String
    , icon : Icon
    }
    -> SidebarLink
new props =
    SidebarLink
        { label = props.label
        , icon = props.icon
        , path = Nothing
        , isSelected = False
        }


withRoutePath : Path -> SidebarLink -> SidebarLink
withRoutePath path (SidebarLink props) =
    SidebarLink { props | path = Just path }


withSelectedStyle : Bool -> SidebarLink -> SidebarLink
withSelectedStyle isSelected (SidebarLink props) =
    SidebarLink { props | isSelected = isSelected }


view : SidebarLink -> Html msg
view (SidebarLink props) =
    a
        [ Css.row
        , Css.pad_16
        , Css.padRight_24
        , Css.gap_8
        , Css.align_left
        , Css.align_cy
        , Html.Attributes.Extra.attributeMaybe
            Route.Path.href
            props.path
        , Css.sidebar_link
        , Html.Attributes.Extra.attributeIf
            props.isSelected
            Css.sidebar_link__selected
        ]
        [ Components.Icon.view16 props.icon
        , span
            [ Css.font_linkLabel
            , Css.ellipsis
            ]
            [ text props.label ]
        ]
