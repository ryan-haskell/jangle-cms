module Pages.Home_ exposing (..)

import Auth
import Components.Button
import Components.Dialog
import Components.EmptyState
import Components.Field
import Components.Icon
import Components.Input
import Components.Layout
import Components.List
import Css
import Effect exposing (Effect)
import GitHub.Queries.RecentRepos
import GitHub.Queries.RecentRepos.Input
import GitHub.Relay
import GitHub.Response
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path exposing (Path)
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init user
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
    , repos : GitHub.Response.Response (List Repo)
    }


type alias Repo =
    GitHub.Queries.RecentRepos.Repository


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { createProjectSearchValue = ""
      , repos = GitHub.Response.Loading
      }
    , case user.githubUsername of
        Just username ->
            Effect.sendGitHubGraphQL
                { operation =
                    let
                        input : GitHub.Queries.RecentRepos.Input
                        input =
                            GitHub.Queries.RecentRepos.Input.new
                                |> GitHub.Queries.RecentRepos.Input.username username
                    in
                    GitHub.Queries.RecentRepos.new input
                , onResponse = FetchedRecentRepos username
                }

        Nothing ->
            -- TODO: Report to Sentry
            Effect.none
    )



-- UPDATE


type Msg
    = ClickedCreateFirstProject
    | ChangedSearchValue String
    | SelectedRepo Repo
    | FetchedRecentRepos String (Result Http.Error GitHub.Queries.RecentRepos.Data)


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

        SelectedRepo repo ->
            ( model
            , Effect.none
            )

        FetchedRecentRepos username (Ok data) ->
            ( { model
                | repos =
                    case data.user of
                        Nothing ->
                            GitHub.Response.Failure (Http.BadBody ("Couldn't find user: " ++ username))

                        Just user ->
                            user.repositories
                                |> GitHub.Relay.toNodes
                                |> GitHub.Response.Success
              }
            , Effect.none
              -- TODO: Report to Sentry
            )

        FetchedRecentRepos username (Err httpError) ->
            ( { model | repos = GitHub.Response.Failure httpError }
            , Effect.none
              -- TODO: Report to Sentry
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
                    , Components.List.view
                        { items =
                            case model.repos of
                                GitHub.Response.Loading ->
                                    []

                                GitHub.Response.Failure _ ->
                                    []

                                GitHub.Response.Success repos ->
                                    List.map toListItem repos
                        }
                    ]
                ]
            }
            |> Components.Dialog.withSubtitle "Connect to an existing GitHub repository"
            |> Components.Dialog.withId ids.createProjectDialog
            |> Components.Dialog.view
        ]
    }


toListItem : Repo -> Components.List.Item Msg
toListItem repo =
    { icon = Components.Icon.GitHub
    , label = repo.nameWithOwner
    , onClick = SelectedRepo repo
    }
