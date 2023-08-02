module Pages.Home_ exposing (..)

import Auth
import Components.Button
import Components.Dialog
import Components.EmptyState
import Components.Field
import Components.Icon
import Components.Input
import Components.Layout
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path exposing (Path)
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view user
        }
        |> Page.withLayout
            (\_ ->
                Layouts.Header
                    { title = "Dashboard"
                    , user = user
                    }
            )



-- INIT


type alias Model =
    { createProjectSearchValue : String
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { createProjectSearchValue = "" }
    , Effect.none
    )



-- UPDATE


type Msg
    = ClickedCreateFirstProject
    | ChangedSearchValue String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedCreateFirstProject ->
            ( { model | createProjectSearchValue = "" }
            , Effect.showDialog { id = ids.createProjectDialog }
            )

        ChangedSearchValue str ->
            ( { model | createProjectSearchValue = str }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


ids :
    { createProjectDialog : String
    , createFirstProjectButton : String
    }
ids =
    { createProjectDialog = "dialog__create-project"
    , createFirstProjectButton = "button__create-first-project"
    }


view : Auth.User -> Model -> View Msg
view user model =
    { title = "Jangle | Dashboard"
    , body =
        [ div [ Css.col, Css.fill, Css.align_center ]
            [ Components.EmptyState.viewCreateYourFirstProject
                { id = ids.createFirstProjectButton
                , onClick = ClickedCreateFirstProject
                }
            , div [ Css.h_96 ] []
            ]
        , Components.Dialog.new
            { title = "Create a project"
            , content =
                [ div [ Css.col, Css.gap_16 ]
                    [ Components.Field.new
                        { input =
                            Components.Input.new
                                { value = model.createProjectSearchValue
                                }
                                |> Components.Input.withStyleSearch
                                |> Components.Input.withOnInput ChangedSearchValue
                        }
                        |> Components.Field.withWidthFill
                        |> Components.Field.withLabel "Find a repository"
                        |> Components.Field.view
                    ]
                ]
            }
            |> Components.Dialog.withSubtitle "Connect to an existing GitHub repository"
            |> Components.Dialog.withId ids.createProjectDialog
            |> Components.Dialog.view
        ]
    }
