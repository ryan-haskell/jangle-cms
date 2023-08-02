module Components.Header exposing
    ( Header, new
    , withUserControls
    , view
    )

{-|

@docs Header, new
@docs withUserControls
@docs view

-}

import Components.UserControls
import Css
import Html exposing (..)
import Html.Extra


type Header msg
    = Header
        { title : String
        , userControls : Maybe (Components.UserControls.UserControls msg)
        }


new : { title : String } -> Header msg
new props =
    Header { title = props.title, userControls = Nothing }


withUserControls :
    Components.UserControls.UserControls msg
    -> Header msg
    -> Header msg
withUserControls userControls (Header header) =
    Header { header | userControls = Just userControls }


view : Header msg -> Html msg
view (Header props) =
    let
        viewTitle : Html msg
        viewTitle =
            h1 [ Css.ellipsis, Css.font_h1 ] [ text props.title ]

        viewUserControls : Html msg
        viewUserControls =
            Html.Extra.viewMaybe
                (\userControls ->
                    userControls
                        |> Components.UserControls.withIconOnMobile
                        |> Components.UserControls.view
                )
                props.userControls
    in
    header
        [ Css.row
        , Css.h_96
        , Css.w_fill
        , Css.shrink_none
        , Css.sticky
        , Css.z1
        , Css.borderBottom
        , Css.bg_background
        , Css.overflow_hidden
        , Css.content_box
        , Css.align_center
        ]
        [ div
            [ Css.row
            , Css.gap_fill
            , Css.gap_32
            , Css.padX_32
            , Css.w_fill
            , Css.mw_1200
            , Css.align_cy
            ]
            [ viewTitle
            , viewUserControls
            ]
        ]
