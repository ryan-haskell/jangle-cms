module Components.List exposing (view)

import Components.Icon
import Css
import Html exposing (..)
import Html.Events


view : { items : List (Item msg) } -> Html msg
view props =
    let
        viewItem : Item msg -> Html msg
        viewItem item =
            button
                [ Css.bg_background
                , Css.row
                , Css.gap_16
                , Css.gap_fill
                , Css.controls
                , Css.shrink_none
                , Css.align_cy
                , Css.h_40
                , Css.padX_12
                , Html.Events.onClick item.onClick
                ]
                [ div [ Css.row, Css.align_cy, Css.gap_8 ]
                    [ Components.Icon.view24 item.icon
                    , span [ Css.font_label ] [ text item.label ]
                    ]
                , Components.Icon.view16 Components.Icon.Right
                ]
    in
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
            (List.map viewItem props.items)
        ]


type alias Item msg =
    { icon : Components.Icon.Icon
    , label : String
    , onClick : msg
    }
