module Components.Avatar exposing (view)

import Css
import Html exposing (..)
import Html.Attributes as Attr


view :
    { label : String
    , sublabel : String
    , image : Maybe String
    }
    -> Html msg
view props =
    let
        viewImage : Html msg
        viewImage =
            let
                backgroundImageAttribute : Html.Attribute msg
                backgroundImageAttribute =
                    case props.image of
                        Nothing ->
                            Attr.classList []

                        Just imageUrl ->
                            Attr.style "background-image"
                                ("url('${imageUrl}')"
                                    |> String.replace "${imageUrl}" imageUrl
                                )
            in
            div
                [ Css.shrink_none
                , Css.w_32
                , Css.h_32
                , Css.radius_circle
                , Css.bg_gray200
                , Css.bg_image
                , backgroundImageAttribute
                ]
                []

        viewLabelAndSubLabel : Html msg
        viewLabelAndSubLabel =
            div [ Css.overflow_hidden, Css.col ]
                [ span [ Css.ellipsis, Css.font_label ] [ text props.label ]
                , span [ Css.ellipsis, Css.font_sublabel, Css.color_textSecondary ] [ text props.sublabel ]
                ]
    in
    div [ Css.row, Css.align_cy, Css.gap_8, Css.overflow_hidden ]
        [ viewImage
        , viewLabelAndSubLabel
        ]
