module Stories.Icon exposing (iconOptions, main)

import Components.Icon exposing (Icon)
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { icon : Maybe Icon
    , view : Maybe (Icon -> Html Msg)
    }


iconOptions : List ( String, Icon )
iconOptions =
    [ ( "GitHub", Components.Icon.GitHub )
    , ( "Google", Components.Icon.Google )
    , ( "Home", Components.Icon.Home )
    , ( "Menu", Components.Icon.Menu )
    , ( "Edit", Components.Icon.Edit )
    , ( "Page", Components.Icon.Page )
    , ( "Down", Components.Icon.Down )
    , ( "Right", Components.Icon.Right )
    , ( "Close", Components.Icon.Close )
    , ( "Search", Components.Icon.Search )
    ]


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "icon"
            , options = iconOptions
            }
        |> Storybook.Controls.withSelect
            { id = "size"
            , options =
                [ ( "16px", Components.Icon.view16 )
                , ( "24px", Components.Icon.view24 )
                ]
            }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.new
        { controls = decoder
        , view = view
        }


type Msg
    = NothingHappened



-- VIEW


view : Controls -> Html Msg
view controls =
    let
        viewIcon : Icon -> Html Msg
        viewIcon =
            controls.view
                |> Maybe.withDefault Components.Icon.view16

        icon : Icon
        icon =
            controls.icon
                |> Maybe.withDefault Components.Icon.GitHub
    in
    viewIcon icon
