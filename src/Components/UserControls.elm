module Components.UserControls exposing
    ( UserControls, new
    , withOnClick, withWidthFill
    , withIconOnMobile
    , view
    )

{-|

@docs UserControls, new
@docs withOnClick, withWidthFill
@docs withIconOnMobile

@docs view

-}

import Components.Avatar
import Components.Icon
import Components.IconButton
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Attributes.Extra
import Html.Events
import Html.Extra


type UserControls msg
    = UserControls
        { user :
            { name : String
            , email : String
            , image : Maybe String
            }
        , onClick : Maybe msg
        , isWidthFill : Bool
        , isResponsive : Bool
        }


new :
    { user :
        { user
            | name : String
            , email : String
            , image : Maybe String
        }
    }
    -> UserControls msg
new props =
    UserControls
        { user =
            { name = props.user.name
            , email = props.user.email
            , image = props.user.image
            }
        , onClick = Nothing
        , isWidthFill = False
        , isResponsive = False
        }


withOnClick : msg -> UserControls msg -> UserControls msg
withOnClick onClick (UserControls props) =
    UserControls { props | onClick = Just onClick }


withWidthFill : UserControls msg -> UserControls msg
withWidthFill (UserControls props) =
    UserControls { props | isWidthFill = True }


withIconOnMobile : UserControls msg -> UserControls msg
withIconOnMobile (UserControls props) =
    UserControls { props | isResponsive = True }


view : UserControls msg -> Html msg
view (UserControls props) =
    let
        onClickAttribute : Html.Attribute msg
        onClickAttribute =
            Html.Attributes.Extra.attributeMaybe
                Html.Events.onClick
                props.onClick

        viewDefaultButton =
            button
                [ Css.row
                , Html.Attributes.Extra.attributeIf
                    props.isResponsive
                    Css.mobile_hide
                , Css.gap_16
                , Css.gap_fill
                , Css.align_cy
                , Css.bg_background
                , Css.border
                , Css.mw_fill
                , Css.pad_16
                , Html.Attributes.Extra.attributeIf
                    props.isWidthFill
                    Css.fill
                , Css.radius_8
                , Css.controls
                , onClickAttribute
                , Attr.attribute "aria-label" "Manage user settings"
                ]
                [ Components.Avatar.view
                    { label = props.user.name
                    , sublabel = props.user.email
                    , image = props.user.image
                    }
                , Components.Icon.view24 Components.Icon.Down
                ]

        viewMobileButton =
            div [ Css.mobile_only ]
                [ Components.IconButton.new
                    { label = "Manage user settings"
                    , icon = Components.Icon.Menu
                    }
                    |> (case props.onClick of
                            Just onClick ->
                                Components.IconButton.withOnClick onClick

                            Nothing ->
                                identity
                       )
                    |> Components.IconButton.view
                ]
    in
    div
        [ Css.row
        , Html.Attributes.Extra.attributeIf
            props.isWidthFill
            Css.fill
        , Css.mw_fill
        ]
        [ viewDefaultButton
        , Html.Extra.viewIf
            props.isResponsive
            viewMobileButton
        ]
