module Components.Field exposing
    ( Field, new
    , withLabel, withLabelAndSublabel
    , withErrorMessage
    , withWidthFill
    , view
    )

{-|

@docs Field, new
@docs withLabel, withLabelAndSublabel
@docs withErrorMessage
@docs withWidthFill
@docs view

-}

import Components.Input
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Svg
import Svg.Attributes as SvgAttr


type Field msg
    = Field
        { label : Label
        , error : Maybe String
        , input : Components.Input.Input msg
        , isWidthFill : Bool
        }


type Label
    = None
    | Label String
    | LabelAndSublabel
        { label : String
        , sublabel : String
        }


new : { input : Components.Input.Input msg } -> Field msg
new props =
    Field
        { label = None
        , error = Nothing
        , input = props.input
        , isWidthFill = False
        }


withLabel : String -> Field msg -> Field msg
withLabel label (Field props) =
    Field { props | label = Label label }


withLabelAndSublabel :
    { label : String
    , sublabel : String
    }
    -> Field msg
    -> Field msg
withLabelAndSublabel labelAndSublabel (Field props) =
    Field { props | label = LabelAndSublabel labelAndSublabel }


withErrorMessage : Maybe String -> Field msg -> Field msg
withErrorMessage error (Field props) =
    Field { props | error = error }


withWidthFill : Field msg -> Field msg
withWidthFill (Field props) =
    Field { props | isWidthFill = True }


view : Field msg -> Html msg
view (Field props) =
    let
        viewLabels : Html msg
        viewLabels =
            let
                viewLabel : String -> Html msg
                viewLabel label =
                    span [ Css.font_label ] [ text label ]
            in
            case props.label of
                None ->
                    text ""

                Label label ->
                    viewLabel label

                LabelAndSublabel { label, sublabel } ->
                    div [ Css.col, Css.gap_4 ]
                        [ viewLabel label
                        , span
                            [ Css.font_sublabel
                            , Css.color_textSecondary
                            ]
                            [ text sublabel ]
                        ]

        viewError : Html msg
        viewError =
            case props.error of
                Nothing ->
                    text ""

                Just error ->
                    div [ Css.row, Css.align_cy, Css.gap_4, Css.padX_8 ]
                        [ viewErrorIcon
                        , span
                            [ Css.font_sublabel
                            , Css.ellipsis
                            ]
                            [ text error ]
                        ]

        widthAttr : Html.Attribute msg
        widthAttr =
            if props.isWidthFill then
                Css.w_fill

            else
                Attr.classList []

        viewInput : Html msg
        viewInput =
            props.input
                |> Components.Input.withError (props.error /= Nothing)
                |> (if props.isWidthFill then
                        Components.Input.withWidthFill

                    else
                        identity
                   )
                |> Components.Input.view
    in
    label [ Css.col, Css.gap_8, widthAttr ]
        [ viewLabels
        , viewInput
        , viewError
        ]


viewErrorIcon : Svg.Svg msg
viewErrorIcon =
    Svg.svg
        [ SvgAttr.width "12"
        , SvgAttr.height "12"
        , SvgAttr.viewBox "0 0 12 12"
        , SvgAttr.fill "none"
        ]
        [ Svg.g
            [ SvgAttr.clipPath "url(#clip0_64_2190)"
            ]
            [ Svg.path
                [ SvgAttr.d "M4.855 0.708011C5.355 -0.187989 6.645 -0.187989 7.145 0.708011L11.82 9.05901C11.9321 9.2588 11.9899 9.48446 11.9878 9.71354C11.9856 9.94263 11.9234 10.1671 11.8075 10.3648C11.6916 10.5624 11.526 10.7262 11.3271 10.8399C11.1283 10.9536 10.9031 11.0133 10.674 11.013H1.33C1.1008 11.0133 0.875508 10.9536 0.676538 10.8398C0.477569 10.726 0.311851 10.5621 0.195864 10.3644C0.0798776 10.1667 0.0176628 9.94213 0.0154064 9.71294C0.01315 9.48374 0.0709306 9.25795 0.183003 9.05801L4.855 0.708011ZM7 7.00001V3.00001H5V7.00001H7ZM6 10C6.26522 10 6.51957 9.89465 6.70711 9.70712C6.89465 9.51958 7 9.26523 7 9.00001C7 8.73479 6.89465 8.48044 6.70711 8.2929C6.51957 8.10537 6.26522 8.00001 6 8.00001C5.73479 8.00001 5.48043 8.10537 5.2929 8.2929C5.10536 8.48044 5 8.73479 5 9.00001C5 9.26523 5.10536 9.51958 5.2929 9.70712C5.48043 9.89465 5.73479 10 6 10Z"
                , SvgAttr.fill "var(--color_primary)"
                ]
                []
            ]
        , Svg.defs []
            [ Svg.clipPath
                [ SvgAttr.id "clip0_64_2190"
                ]
                [ Svg.rect
                    [ SvgAttr.width "12"
                    , SvgAttr.height "12"
                    , SvgAttr.fill "var(--color_white)"
                    ]
                    []
                ]
            ]
        ]
