module Stories.EmptyState exposing (main)

import Components.EmptyState
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { view : Maybe (Html Msg)
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "variant"
            , options =
                [ ( "CreateYourFirstProject"
                  , Components.EmptyState.viewCreateYourFirstProject
                        { onClick = ClickedCreateNewProject
                        }
                  )
                ]
            }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.simple
        { controls = decoder
        , view = view
        }


type Msg
    = ClickedCreateNewProject



-- VIEW


view : Controls -> Html Msg
view controls =
    case controls.view of
        Just viewSelectedEmptyState ->
            viewSelectedEmptyState

        Nothing ->
            Components.EmptyState.viewCreateYourFirstProject
                { onClick = ClickedCreateNewProject
                }
