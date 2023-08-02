module Components.IconButton exposing
    ( IconButton, new
    , withOnClick
    , view
    )

{-|

@docs IconButton, new
@docs withOnClick

@docs view

-}

import Components.Icon exposing (Icon)
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Attributes.Extra
import Html.Events


type IconButton msg
    = IconButton
        { label : String
        , icon : Icon
        , onClick : Maybe msg
        }


new : { label : String, icon : Icon } -> IconButton msg
new props =
    IconButton
        { label = props.label
        , icon = props.icon
        , onClick = Nothing
        }


withOnClick : msg -> IconButton msg -> IconButton msg
withOnClick onClick (IconButton props) =
    IconButton { props | onClick = Just onClick }


view : IconButton msg -> Html msg
view (IconButton props) =
    button
        [ Css.pad_8
        , Css.border
        , Css.radius_8
        , Css.bg_background
        , Css.controls
        , Attr.attribute "aria-label" props.label
        , Html.Attributes.Extra.attributeMaybe
            Html.Events.onClick
            props.onClick
        ]
        [ Components.Icon.view16 props.icon
        ]
