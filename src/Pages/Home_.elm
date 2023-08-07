module Pages.Home_ exposing (..)

import Auth
import Auth.User
import Components.Button
import Components.Dialog
import Components.EmptyState
import Components.Field
import Components.Icon
import Components.Input
import Components.Layout
import Components.List
import Css
import Dict exposing (Dict)
import Effect exposing (Effect)
import GitHub.Queries.RecentRepos
import GitHub.Queries.RecentRepos.Input
import GitHub.Queries.SearchRepos
import GitHub.Queries.SearchRepos.Input
import GitHub.Queries.SearchRepos.SearchResultItem as SearchResultItem
import GraphQL.Relay
import GraphQL.Response exposing (Response)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Http
import Json.Encode
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path exposing (Path)
import Shared
import String.Extra
import Supabase.Mutations.CreateProject
import Supabase.Mutations.CreateProject.Input
import Supabase.Scalars.UUID
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init user
        , update = update user
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
    { searchQuery : String
    , recentRepos : Response (List Repo)
    , searchRepos : Maybe (Response (List Repo))
    , newProject : Maybe (Response Supabase.Mutations.CreateProject.Data)
    }


type alias Repo =
    GitHub.Queries.RecentRepos.Repository


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { searchQuery = ""
      , recentRepos = GraphQL.Response.Loading
      , searchRepos = Nothing
      , newProject = Nothing
      }
    , case user.github of
        Just { username } ->
            let
                input : GitHub.Queries.RecentRepos.Input
                input =
                    GitHub.Queries.RecentRepos.Input.new
                        |> GitHub.Queries.RecentRepos.Input.username username
            in
            Effect.sendGitHubGraphQL
                { operation = GitHub.Queries.RecentRepos.new input
                , onResponse = FetchedRecentRepos username
                }

        Nothing ->
            Effect.sendCustomErrorToSentry
                { message = "Could not fetch recent repos, because user was missing"
                , details = []
                }
    )



-- UPDATE


type Msg
    = ClickedCreateFirstProject
    | ChangedSearchValue Auth.User.GitHubInfo String
    | SelectedRepo Int Repo
    | ThrottledSearchRepos { username : String, searchQuery : String }
    | FetchedRecentRepos String (Result Http.Error GitHub.Queries.RecentRepos.Data)
    | FetchedSearchRepos (Result Http.Error GitHub.Queries.SearchRepos.Data)
    | FetchedCreateNewProject (Result Http.Error Supabase.Mutations.CreateProject.Data)


update : Auth.User -> Msg -> Model -> ( Model, Effect Msg )
update user msg model =
    case msg of
        ClickedCreateFirstProject ->
            ( { model
                | searchQuery = ""
                , newProject = Nothing
                , searchRepos = Nothing
              }
            , Effect.showDialog { id = ids.createProjectDialog }
            )

        ChangedSearchValue { username } searchQuery ->
            ( { model
                | searchQuery = searchQuery
                , searchRepos = Just GraphQL.Response.Loading
              }
            , if String.Extra.isBlank searchQuery then
                Effect.none

              else
                -- Prevents sending a query on each keystroke
                Effect.sendDelayedMsg 300
                    (ThrottledSearchRepos
                        { username = username
                        , searchQuery = searchQuery
                        }
                    )
            )

        ThrottledSearchRepos { username, searchQuery } ->
            ( model
            , if searchQuery == model.searchQuery then
                let
                    input : GitHub.Queries.SearchRepos.Input
                    input =
                        GitHub.Queries.SearchRepos.Input.new
                            |> GitHub.Queries.SearchRepos.Input.searchQuery
                                (String.join " "
                                    [ "user:" ++ username
                                    , searchQuery
                                    ]
                                )
                in
                Effect.sendGitHubGraphQL
                    { operation = GitHub.Queries.SearchRepos.new input
                    , onResponse = FetchedSearchRepos
                    }

              else
                Effect.none
            )

        SelectedRepo repoId repo ->
            let
                input : Supabase.Mutations.CreateProject.Input
                input =
                    Supabase.Mutations.CreateProject.Input.new
                        |> Supabase.Mutations.CreateProject.Input.title repo.name
                        |> Supabase.Mutations.CreateProject.Input.githubRepoId (String.fromInt repoId)
                        |> Supabase.Mutations.CreateProject.Input.userId user.id
            in
            ( { model | newProject = Just GraphQL.Response.Loading }
            , Effect.sendSupabaseGraphQL
                { operation = Supabase.Mutations.CreateProject.new input
                , onResponse = FetchedCreateNewProject
                }
            )

        FetchedRecentRepos username (Ok data) ->
            case data.user of
                Nothing ->
                    ( { model
                        | recentRepos =
                            ("Couldn't find user: " ++ username)
                                |> Http.BadBody
                                |> GraphQL.Response.Failure
                      }
                    , Effect.sendCustomErrorToSentry
                        { message = "GitHub could not find user"
                        , details =
                            [ ( "username", Json.Encode.string username )
                            ]
                        }
                    )

                Just user_ ->
                    ( { model
                        | recentRepos =
                            user_.repositories
                                |> GraphQL.Relay.toNodes
                                |> GraphQL.Response.Success
                      }
                    , Effect.none
                    )

        FetchedRecentRepos username (Err httpError) ->
            ( { model | recentRepos = GraphQL.Response.Failure httpError }
            , Effect.none
            )

        FetchedSearchRepos (Ok data) ->
            let
                toRepo :
                    SearchResultItem.SearchResultItem
                    -> Maybe SearchResultItem.Repository
                toRepo searchResultItem =
                    case searchResultItem of
                        SearchResultItem.OnRepository repo ->
                            Just repo
            in
            ( { model
                | searchRepos =
                    GraphQL.Relay.toNodes data.search
                        |> List.filterMap toRepo
                        |> GraphQL.Response.Success
                        |> Just
              }
            , Effect.none
            )

        FetchedSearchRepos (Err httpError) ->
            ( { model
                | searchRepos =
                    httpError
                        |> GraphQL.Response.Failure
                        |> Just
              }
            , Effect.none
            )

        FetchedCreateNewProject (Ok data) ->
            case data.projects.records of
                [] ->
                    ( { model
                        | newProject = Just (GraphQL.Response.Failure (Http.BadBody "No records were created"))
                      }
                    , Effect.sendCustomErrorToSentry
                        { message = "Create new project returned no new values"
                        , details = []
                        }
                    )

                project :: _ ->
                    ( { model | newProject = Just (GraphQL.Response.Success data) }
                    , Effect.pushRoute
                        { path =
                            Route.Path.Projects_ProjectId_
                                { projectId = Supabase.Scalars.UUID.toString project.id
                                }
                        , query = Dict.empty
                        , hash = Nothing
                        }
                    )

        FetchedCreateNewProject (Err httpError) ->
            ( { model | newProject = Just (GraphQL.Response.Failure httpError) }
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
                [ case user.github of
                    Nothing ->
                        text "Connect to GitHub"

                    Just githubInfo ->
                        viewCreateProjectForm githubInfo model
                ]
            }
            |> Components.Dialog.withSubtitle "Connect to an existing GitHub repository"
            |> Components.Dialog.withId ids.createProjectDialog
            |> Components.Dialog.view
        ]
    }


viewCreateProjectForm : Auth.User.GitHubInfo -> Model -> Html Msg
viewCreateProjectForm githubInfo model =
    let
        viewRepoNameSearchField : Html Msg
        viewRepoNameSearchField =
            Components.Field.new
                { input =
                    Components.Input.new
                        { value = model.searchQuery
                        }
                        |> Components.Input.withStyleSearch
                        |> Components.Input.withOnInput (ChangedSearchValue githubInfo)
                }
                |> Components.Field.withWidthFill
                |> Components.Field.withLabel "Find a repository"
                |> Components.Field.view

        viewRepoOptions : Html Msg
        viewRepoOptions =
            if String.isEmpty model.searchQuery then
                viewRecentRepoOptions

            else
                viewFilteredRepoOptions

        viewFilteredRepoOptions : Html Msg
        viewFilteredRepoOptions =
            case model.searchRepos of
                Nothing ->
                    Components.EmptyState.viewLoading

                Just GraphQL.Response.Loading ->
                    Components.EmptyState.viewLoading

                Just (GraphQL.Response.Failure httpError) ->
                    Components.EmptyState.viewHttpError httpError

                Just (GraphQL.Response.Success repos) ->
                    if List.isEmpty repos then
                        Components.EmptyState.viewNoResultsFound
                            "No repositories found matching your search"

                    else
                        Components.List.view { items = List.filterMap toListItem repos }

        viewRecentRepoOptions : Html Msg
        viewRecentRepoOptions =
            case model.recentRepos of
                GraphQL.Response.Loading ->
                    Components.EmptyState.viewLoading

                GraphQL.Response.Failure httpError ->
                    Components.EmptyState.viewHttpError httpError

                GraphQL.Response.Success repos ->
                    Components.List.view { items = List.filterMap toListItem repos }
    in
    div [ Css.col, Css.gap_16 ]
        [ viewRepoNameSearchField
        , case model.newProject of
            Nothing ->
                viewRepoOptions

            Just GraphQL.Response.Loading ->
                Components.EmptyState.viewLoading

            Just (GraphQL.Response.Failure httpError) ->
                -- TODO: Show a "Try again" option
                Components.EmptyState.viewHttpError httpError

            Just (GraphQL.Response.Success repos) ->
                Components.EmptyState.viewLoading
        ]


toListItem : Repo -> Maybe (Components.List.Item Msg)
toListItem repo =
    case repo.databaseId of
        Nothing ->
            Nothing

        Just repoId ->
            Just
                { icon = Components.Icon.GitHub
                , label = repo.nameWithOwner
                , onClick = SelectedRepo repoId repo
                }
