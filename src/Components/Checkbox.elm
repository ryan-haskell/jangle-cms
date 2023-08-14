module Components.Checkbox exposing (view)

import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events


view :
    { label : String, isChecked : Bool, onCheck : Bool -> msg }
    -> Html msg
view props =
    label [ Css.row, Css.gap_8, Css.align_cy ]
        [ input
            [ Attr.type_ "checkbox"
            , Attr.checked props.isChecked
            , Html.Events.onCheck props.onCheck
            ]
            []
        , span
            [ Css.ellipsis
            , Css.font_sublabel
            , Css.not_selectable
            ]
            [ text props.label ]
        ]
