module Components.UserControls exposing
    ( UserControls, new
    , withOnClick
    , view
    )

{-|

@docs UserControls, new
@docs withOnClick

@docs view

-}

import Components.Avatar
import Components.Icon
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events


type UserControls msg
    = UserControls
        { user :
            { name : String
            , email : String
            , image : Maybe String
            }
        , onClick : Maybe msg
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
        }


withOnClick : msg -> UserControls msg -> UserControls msg
withOnClick onClick (UserControls props) =
    UserControls { props | onClick = Just onClick }


view : UserControls msg -> Html msg
view (UserControls props) =
    button
        [ Css.row
        , Css.gap_16
        , Css.gap_fill
        , Css.align_cy
        , Css.bg_background
        , Css.border
        , Css.mw_fill
        , Css.pad_16
        , Css.fill
        , Css.radius_8
        , Css.user_controls
        , case props.onClick of
            Just onClick ->
                Html.Events.onClick onClick

            Nothing ->
                Attr.classList []
        ]
        [ Components.Avatar.view
            { label = props.user.name
            , sublabel = props.user.email
            , image = props.user.image
            }
        , Components.Icon.view24 Components.Icon.Down
        ]
