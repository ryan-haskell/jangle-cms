module Components.Header exposing (view)

import Css
import Html exposing (..)


view : { title : String } -> Html msg
view props =
    header
        [ Css.row
        , Css.h_96
        , Css.padX_32
        , Css.align_cy
        , Css.borderBottom
        , Css.bg_background
        , Css.overflow_hidden
        ]
        [ h1 [ Css.ellipsis, Css.font_h1 ] [ text props.title ]
        ]
