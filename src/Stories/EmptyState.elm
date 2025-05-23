module Stories.EmptyState exposing (main)

import Components.EmptyState
import Html exposing (Html)
import Http
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
                  , viewCreateYourFirstProject
                  )
                , ( "Loading"
                  , Components.EmptyState.viewLoading
                  )
                , ( "HttpError"
                  , Components.EmptyState.viewHttpError Http.NetworkError
                  )
                , ( "NoResultsFound"
                  , Components.EmptyState.viewNoResultsFound "No repositories found matching your search"
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
            viewCreateYourFirstProject


viewCreateYourFirstProject =
    Components.EmptyState.viewCreateYourFirstProject
        { id = "button__create-first-project"
        , onClick = ClickedCreateNewProject
        }
