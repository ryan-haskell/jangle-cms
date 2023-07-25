module Components.Button exposing
    ( Button, new
    , view
    , withOnClick, withHref
    , withStyleSecondary
    )

{-|

@docs Button, new
@docs view

@docs withOnClick, withHref
@docs withStyleSecondary

-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events



-- BUTTON


type Button msg
    = Button
        { label : String
        , onClick : Maybe (Action msg)
        , style : Style
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
        , style = Primary
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



-- VIEW


view : Button msg -> Html msg
view (Button props) =
    viewElement props.onClick
        [ Attr.class "button"
        , Attr.classList
            [ ( "button--secondary", props.style == Secondary )
            ]
        ]
        [ Html.text props.label
        ]


viewElement :
    Maybe (Action msg)
    -> List (Html.Attribute msg)
    -> List (Html msg)
    -> Html msg
viewElement maybeAction attributes children =
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
