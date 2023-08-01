module Stories.JangleLogo exposing (main)

import Components.JangleLogo
import Html exposing (Html)
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { size : Maybe Size
    }


type Size
    = Small
    | Large


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "size"
            , options =
                [ ( "Small", Small )
                , ( "Large", Large )
                ]
            }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.simple
        { controls = decoder
        , view = view
        }


type Msg
    = NoOp



-- VIEW


view : Controls -> Html Msg
view controls =
    case controls.size of
        Nothing ->
            Components.JangleLogo.viewSmall

        Just Small ->
            Components.JangleLogo.viewSmall

        Just Large ->
            Components.JangleLogo.viewLarge
