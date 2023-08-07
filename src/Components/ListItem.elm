module Components.ListItem exposing
    ( ListItem, new
    , withHref, withOnClick
    , view
    )

{-|

@docs ListItem, new
@docs withHref, withOnClick
@docs view

-}

import Components.Icon
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events


type ListItem msg
    = Item
        { icon : Components.Icon.Icon
        , label : String
        , action : Maybe (Action msg)
        }


type Action msg
    = SendMsg msg
    | Href String


new :
    { icon : Components.Icon.Icon
    , label : String
    }
    -> ListItem msg
new props =
    Item
        { icon = props.icon
        , label = props.label
        , action = Nothing
        }



-- MODIFIERS


withHref : String -> ListItem msg -> ListItem msg
withHref url (Item props) =
    Item { props | action = Just (Href url) }


withOnClick : msg -> ListItem msg -> ListItem msg
withOnClick onClickMsg (Item props) =
    Item { props | action = Just (SendMsg onClickMsg) }



-- VIEW


view : ListItem msg -> Html msg
view (Item props) =
    viewClickableElement props.action
        [ Css.bg_background
        , Css.row
        , Css.gap_16
        , Css.gap_fill
        , Css.controls
        , Css.shrink_none
        , Css.align_cy
        , Css.h_40
        , Css.padX_12
        ]
        [ div [ Css.row, Css.align_cy, Css.gap_8, Css.overflow_hidden ]
            [ Components.Icon.view24 props.icon
            , span [ Css.font_label, Css.ellipsis ] [ text props.label ]
            ]
        , Components.Icon.view16 Components.Icon.Right
        ]


viewClickableElement :
    Maybe (Action msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewClickableElement maybeAction attrs children =
    case maybeAction of
        Nothing ->
            button attrs children

        Just (SendMsg onClick) ->
            button
                (Html.Events.onClick onClick :: attrs)
                children

        Just (Href url) ->
            a
                (Attr.href url :: attrs)
                children
