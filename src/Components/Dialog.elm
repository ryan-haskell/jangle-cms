module Components.Dialog exposing
    ( Dialog, new
    , withSubtitle, withOnClose
    , withId
    , view
    )

{-|

@docs Dialog, new
@docs withSubtitle, withOnClose
@docs withId

@docs view

-}

import Components.Button
import Components.Icon
import Components.IconButton
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Attributes.Extra
import Html.Events
import Html.Extra
import Json.Decode


type Dialog msg
    = Dialog
        { mode : Mode
        , title : String
        , onClose : Maybe msg
        , content : List (Html msg)
        , subtitle : Maybe String
        }


type Mode
    = AlwaysVisible
    | OpenedByShowModal { id : String }


new :
    { title : String
    , content : List (Html msg)
    }
    -> Dialog msg
new props =
    Dialog
        { mode = AlwaysVisible
        , title = props.title
        , content = props.content
        , subtitle = Nothing
        , onClose = Nothing
        }


withOnClose : msg -> Dialog msg -> Dialog msg
withOnClose onClose (Dialog props) =
    Dialog { props | onClose = Just onClose }


withSubtitle : String -> Dialog msg -> Dialog msg
withSubtitle subtitle (Dialog props) =
    Dialog { props | subtitle = Just subtitle }


withId : String -> Dialog msg -> Dialog msg
withId id (Dialog props) =
    Dialog { props | mode = OpenedByShowModal { id = id } }


view : Dialog msg -> Html msg
view (Dialog props) =
    let
        viewHeader : Html msg
        viewHeader =
            div
                [ Css.col
                , Css.gap_4
                , Css.overflow_hidden
                , Css.padRight_40
                ]
                [ span [ Css.font_h1, Css.ellipsis ] [ text props.title ]
                , Html.Extra.viewMaybe
                    (\subtitle ->
                        span
                            [ Css.font_sublabel
                            , Css.color_textSecondary
                            ]
                            [ text subtitle ]
                    )
                    props.subtitle
                ]

        viewCloseButton : Html msg
        viewCloseButton =
            form
                [ Attr.method "dialog"
                , Attr.style "position" "absolute"
                , Attr.style "top" "2rem"
                , Attr.style "right" "2rem"
                ]
                [ Components.IconButton.new
                    { label = "Close dialog"
                    , icon = Components.Icon.Close
                    }
                    |> Components.IconButton.view
                ]
    in
    node "dialog"
        [ case props.mode of
            AlwaysVisible ->
                Attr.attribute "open" "open"

            OpenedByShowModal { id } ->
                Attr.id id
        , Html.Attributes.Extra.attributeMaybe
            (Html.Events.on "close" << Json.Decode.succeed)
            props.onClose
        ]
        [ div
            [ Css.bg_background
            , Css.col
            , Css.mw_fill
            , Css.w_640
            , Css.border
            , Css.radius_16
            , Css.pad_32
            , Css.gap_32
            , Css.scroll
            , Css.relative
            ]
            [ viewHeader
            , div [ Css.fill ] props.content
            , viewCloseButton
            ]
        ]
