module Components.Layout exposing
    ( Layout, new
    , withHeader, withSidebar
    , withFullWidthContent
    , view
    )

{-|

@docs Layout, new
@docs withHeader, withSidebar
@docs withFullWidthContent
@docs view

-}

import Components.Header
import Components.Icon exposing (Icon)
import Components.Sidebar
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Route.Path exposing (Path)


type Layout msg
    = Layout
        { content : List (Html msg)
        , header : Maybe (Components.Header.Header msg)
        , isContentCentered : Bool
        , sidebar : Maybe (Components.Sidebar.Sidebar msg)
        }


new : { content : List (Html msg) } -> Layout msg
new props =
    Layout
        { content = props.content
        , isContentCentered = True
        , header = Nothing
        , sidebar = Nothing
        }


withHeader :
    Components.Header.Header msg
    -> Layout msg
    -> Layout msg
withHeader header (Layout props) =
    Layout { props | header = Just header }


withFullWidthContent : Layout msg -> Layout msg
withFullWidthContent (Layout props) =
    Layout { props | isContentCentered = False }


withSidebar :
    Components.Sidebar.Sidebar msg
    -> Layout msg
    -> Layout msg
withSidebar sidebar (Layout props) =
    Layout
        { props | sidebar = Just sidebar }


view : Layout msg -> Html msg
view (Layout props) =
    div [ Css.row, Css.h_fill, Css.shrink_none ]
        [ case props.sidebar of
            Just sidebar ->
                Components.Sidebar.view sidebar

            Nothing ->
                text ""
        , main_ [ Css.col, Css.align_cx, Css.fill, Css.scroll ]
            [ case props.header of
                Just header ->
                    Components.Header.view header

                Nothing ->
                    text ""
            , div
                [ Css.w_fill
                , Css.col
                , Css.fill
                , if props.isContentCentered then
                    Css.mw_1200

                  else
                    Attr.classList []
                ]
                props.content
            ]
        ]
