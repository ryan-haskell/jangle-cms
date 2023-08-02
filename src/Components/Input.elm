module Components.Input exposing
    ( Input, new
    , withOnInput
    , withStyleSearch, withStyleMultiline
    , withError
    , withWidthFill
    , view
    )

{-|

@docs Input, new
@docs withOnInput
@docs withStyleSearch, withStyleMultiline
@docs withError
@docs withWidthFill

@docs view

-}

import Components.Icon
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events


type Input msg
    = Input
        { value : String
        , style : Style
        , hasError : Bool
        , onInput : Maybe (String -> msg)
        , isWidthFill : Bool
        }


type Style
    = Text
    | Search
    | Multiline


new : { value : String } -> Input msg
new props =
    Input
        { value = props.value
        , style = Text
        , hasError = False
        , onInput = Nothing
        , isWidthFill = False
        }


withStyleSearch : Input msg -> Input msg
withStyleSearch (Input props) =
    Input { props | style = Search }


withStyleMultiline : Input msg -> Input msg
withStyleMultiline (Input props) =
    Input { props | style = Multiline }


withOnInput : (String -> msg) -> Input msg -> Input msg
withOnInput onInput (Input props) =
    Input { props | onInput = Just onInput }


withError : Bool -> Input msg -> Input msg
withError hasError (Input props) =
    Input { props | hasError = hasError }


withWidthFill : Input msg -> Input msg
withWidthFill (Input props) =
    Input { props | isWidthFill = True }


view : Input msg -> Html msg
view (Input props) =
    let
        onInputAttribute : Html.Attribute msg
        onInputAttribute =
            case props.onInput of
                Nothing ->
                    Attr.classList []

                Just onInput ->
                    Html.Events.onInput onInput

        errorAttribute : Html.Attribute msg
        errorAttribute =
            if props.hasError then
                Css.input__error

            else
                Attr.classList []

        widthAttr : Html.Attribute msg
        widthAttr =
            if props.isWidthFill then
                Css.w_fill

            else
                Attr.classList []
    in
    case props.style of
        Text ->
            input
                [ Css.input
                , Attr.value props.value
                , onInputAttribute
                , errorAttribute
                , widthAttr
                ]
                []

        Search ->
            div [ Css.row, Css.relative, widthAttr ]
                [ div
                    [ Css.absolute
                    , Css.w_40
                    , Css.h_40
                    , Css.row
                    , Css.align_center
                    , Css.color_textSecondary
                    ]
                    [ Components.Icon.view16 Components.Icon.Search
                    ]
                , input
                    [ Css.input
                    , Css.padLeft_40
                    , Attr.value props.value
                    , onInputAttribute
                    , errorAttribute
                    , widthAttr
                    ]
                    []
                ]

        Multiline ->
            textarea
                [ Css.textarea
                , Attr.rows 5
                , Attr.value props.value
                , onInputAttribute
                , errorAttribute
                , widthAttr
                ]
                []
