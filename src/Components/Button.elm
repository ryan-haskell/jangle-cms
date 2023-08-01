module Components.Button exposing
    ( Button, new
    , view
    , withOnClick, withHref
    , withId
    , withStyleSecondary
    , withIcon
    )

{-|

@docs Button, new
@docs view

@docs withOnClick, withHref
@docs withId
@docs withStyleSecondary

-}

import Components.Icon exposing (Icon)
import Css
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events



-- BUTTON


type Button msg
    = Button
        { label : String
        , id : Maybe String
        , onClick : Maybe (Action msg)
        , style : Style
        , icon : Maybe Icon
        }


type Action msg
    = OpenUrl String
    | SendMsg msg


type Style
    = Primary
    | Secondary



-- NEW


new : { label : String } -> Button msg
new props =
    Button
        { label = props.label
        , onClick = Nothing
        , id = Nothing
        , style = Primary
        , icon = Nothing
        }



-- MODIFIERS


withStyleSecondary : Button msg -> Button msg
withStyleSecondary (Button props) =
    Button { props | style = Secondary }


withOnClick : msg -> Button msg -> Button msg
withOnClick onClickMsg (Button props) =
    Button { props | onClick = Just (SendMsg onClickMsg) }


withHref : String -> Button msg -> Button msg
withHref url (Button props) =
    Button { props | onClick = Just (OpenUrl url) }


withId : String -> Button msg -> Button msg
withId id (Button props) =
    Button { props | id = Just id }


withIcon : Icon -> Button msg -> Button msg
withIcon icon (Button props) =
    Button { props | icon = Just icon }



-- VIEW


view : Button msg -> Html msg
view (Button props) =
    viewElement props.onClick
        [ Css.button
        , if props.style == Secondary then
            Css.button__secondary

          else
            Attr.classList []
        , case props.id of
            Just id ->
                Attr.id id

            Nothing ->
                Attr.classList []
        ]
        [ case props.icon of
            Just icon ->
                Components.Icon.view16 icon

            Nothing ->
                Html.text ""
        , Html.span [] [ Html.text props.label ]
        ]


viewElement :
    Maybe (Action msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewElement maybeAction attributes_ children =
    let
        attributes : List (Html.Attribute msg)
        attributes =
            Css.row
                :: Css.gap_8
                :: Css.align_center
                :: attributes_
    in
    case maybeAction of
        Just (OpenUrl url) ->
            Html.a
                (Attr.href url :: attributes)
                children

        Just (SendMsg msg) ->
            Html.button
                (Html.Events.onClick msg :: attributes)
                children

        Nothing ->
            Html.button
                attributes
                children
