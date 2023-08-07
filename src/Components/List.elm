module Components.List exposing (view)

import Components.Icon
import Components.ListItem
import Css
import Html exposing (..)
import Html.Events


view :
    { items : List (Components.ListItem.ListItem msg)
    }
    -> Html msg
view props =
    div [ Css.col, Css.w_fill, Css.h_180 ]
        [ div
            [ Css.col
            , Css.bg_border
            , Css.radius_8
            , Css.scroll
            , Css.gap_1
            , Css.w_fill
            , Css.border
            ]
            (List.map
                Components.ListItem.view
                props.items
            )
        ]
