module Pages.Projects.ProjectId_ exposing (Model, Msg, page)

import Auth
import Components.Dialog
import Components.EmptyState
import Components.Icon
import Components.Layout
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page :
    Auth.User
    -> Shared.Model
    -> Route { projectId : String }
    -> Page Model Msg
page user shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view route
        }
        |> Page.withLayout
            (\_ ->
                Layouts.Sidebar
                    { title = "Project"
                    , user = user
                    , projectId = route.params.projectId
                    }
            )



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ClickedCreateFirstContentType


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedCreateFirstContentType ->
            ( model
            , Effect.showDialog
                { id = ids.createContentTypeDialog
                }
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


ids =
    { createContentTypeButton = "button__createContentType"
    , createContentTypeDialog = "dialog__createContentType"
    }


view :
    Route { projectId : String }
    -> Model
    -> View Msg
view route model =
    { title = "Jangle | Project"
    , body =
        [ div [ Css.col, Css.h_fill, Css.w_fill, Css.pad_32, Css.align_center ]
            [ Components.EmptyState.viewCreateYourFirstContentType
                { id = ids.createContentTypeButton
                , onClick = ClickedCreateFirstContentType
                }
            ]
        , viewCreateContentTypeDialog model
        ]
    }


viewCreateContentTypeDialog : Model -> Html Msg
viewCreateContentTypeDialog model =
    Components.Dialog.new
        { title = "Create a content type"
        , content =
            [ span [ Css.color_textSecondary ]
                [ text "( TODO: Make this a nice form! )"
                ]
            ]
        }
        |> Components.Dialog.withSubtitle "Content types allow you to define what content you'd like to manage"
        |> Components.Dialog.withId ids.createContentTypeDialog
        |> Components.Dialog.view
