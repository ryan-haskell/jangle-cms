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
import Components.ListItem
import Css
import Dict exposing (Dict)
import Effect exposing (Effect)
import GitHub.Mutations.UpdateFile
import GitHub.Mutations.UpdateFile.Input
import GitHub.Queries.DefaultBranchInfo
import GitHub.Queries.DefaultBranchInfo.Input
import GitHub.Queries.RecentRepos
import GitHub.Queries.RecentRepos.Input
import GitHub.Queries.SearchRepos
import GitHub.Queries.SearchRepos.Input
import GitHub.Queries.SearchRepos.SearchResultItem as SearchResultItem
import GitHub.Scalars.Base64String
import GitHub.Scalars.GitObjectID
import GraphQL.Relay
import GraphQL.Response exposing (Response)
import GraphQL.Scalar.Id
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Http
import Jangle.Settings
import Json.Encode
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path exposing (Path)
import Shared
import String.Extra
import Supabase.Mutations.CreateProject
import Supabase.Mutations.CreateProject.Input
import Supabase.Queries.MyProjects exposing (Project)
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
    , projects : Response (List Supabase.Queries.MyProjects.Project)
    , searchRepos : Maybe (Response (List Repo))
    , newProject : Maybe (Response Supabase.Mutations.CreateProject.Data)
    , newProjectBranchInfo : Maybe (Response GitHub.Queries.DefaultBranchInfo.Data)
    , newProjectUpdatedFile : Maybe (Response GitHub.Mutations.UpdateFile.Data)
    }


type alias Repo =
    GitHub.Queries.RecentRepos.Repository


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { searchQuery = ""
      , projects = GraphQL.Response.Loading
      , recentRepos = GraphQL.Response.Loading
      , searchRepos = Nothing
      , newProject = Nothing
      , newProjectBranchInfo = Nothing
      , newProjectUpdatedFile = Nothing
      }
    , Effect.batch
        [ fetchExistingProjects
        , fetchRecentRepos user
        ]
    )


fetchExistingProjects : Effect Msg
fetchExistingProjects =
    Effect.sendSupabaseGraphQL
        { operation = Supabase.Queries.MyProjects.new
        , onResponse = FetchedExistingProjects
        }


fetchRecentRepos : Auth.User -> Effect Msg
fetchRecentRepos user =
    case user.github of
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
            Effect.none



-- UPDATE


type Msg
    = ClickedCreateFirstProject
    | ChangedSearchValue Auth.User.GitHubInfo String
    | SelectedRepoForNewProject
        { repoId : Int
        , owner : String
        , repo : Repo
        }
    | ThrottledSearchRepos { username : String, searchQuery : String }
    | FetchedExistingProjects (Result Http.Error Supabase.Queries.MyProjects.Data)
    | FetchedRecentRepos String (Result Http.Error GitHub.Queries.RecentRepos.Data)
    | FetchedSearchRepos (Result Http.Error GitHub.Queries.SearchRepos.Data)
    | FetchedCreateNewProject
        { owner : String
        , repo : Repo
        }
        (Result Http.Error Supabase.Mutations.CreateProject.Data)
    | FetchedDefaultBranchInfo
        { projectId : Supabase.Scalars.UUID.UUID
        , repo : Repo
        }
        (Result Http.Error GitHub.Queries.DefaultBranchInfo.Data)
    | FetchedUpdateFile Supabase.Scalars.UUID.UUID (Result Http.Error GitHub.Mutations.UpdateFile.Data)
    | ClickedTryAgain


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

        SelectedRepoForNewProject { repoId, owner, repo } ->
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
                , onResponse =
                    FetchedCreateNewProject
                        { owner = owner
                        , repo = repo
                        }
                }
            )

        ClickedTryAgain ->
            ( { model
                | newProject = Nothing
                , newProjectBranchInfo = Nothing
                , newProjectUpdatedFile = Nothing
              }
            , Effect.none
            )

        FetchedExistingProjects (Ok data) ->
            ( { model
                | projects =
                    GraphQL.Response.Success
                        (data.projects
                            |> Maybe.map .edges
                            |> Maybe.map (List.map .node)
                            |> Maybe.withDefault []
                        )
              }
            , Effect.none
            )

        FetchedExistingProjects (Err httpError) ->
            ( { model | projects = GraphQL.Response.Failure httpError }
            , Effect.none
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

        FetchedCreateNewProject info (Ok data) ->
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
                    ( { model
                        | newProject = Just (GraphQL.Response.Success data)
                        , newProjectBranchInfo = Just GraphQL.Response.Loading
                      }
                    , fetchDefaultBranchInfo
                        { projectId = project.id
                        , owner = info.owner
                        , repo = info.repo
                        }
                    )

        FetchedCreateNewProject info (Err httpError) ->
            ( { model | newProject = Just (GraphQL.Response.Failure httpError) }
            , Effect.none
            )

        FetchedDefaultBranchInfo info (Ok data) ->
            let
                showProblem : String -> ( Model, Effect Msg )
                showProblem problem =
                    ( { model | newProjectBranchInfo = Just (GraphQL.Response.Failure (Http.BadBody problem)) }
                    , Effect.none
                    )
            in
            case data.repository of
                Nothing ->
                    showProblem "Expected a repository to be found"

                Just repo ->
                    case repo.defaultBranchRef of
                        Nothing ->
                            showProblem "No default branch found"

                        Just branch ->
                            case branch.target of
                                Nothing ->
                                    showProblem "No commit found for default branch"

                                Just target ->
                                    ( { model | newProjectBranchInfo = Just (GraphQL.Response.Success data) }
                                    , createNewJangleSettingsFile
                                        { repo = info.repo
                                        , projectId = info.projectId
                                        , branchId = branch.id
                                        , expectedHeadOid = target.oid
                                        }
                                    )

        FetchedDefaultBranchInfo info (Err httpError) ->
            ( { model
                | newProjectBranchInfo = Just (GraphQL.Response.Failure httpError)
              }
            , Effect.none
            )

        FetchedUpdateFile projectId (Ok data) ->
            ( { model | newProjectUpdatedFile = Just (GraphQL.Response.Success data) }
            , Effect.batch
                [ Effect.hideDialog
                    { id = ids.createProjectDialog
                    }
                , Effect.pushRoute
                    { path =
                        Route.Path.Projects_ProjectId_
                            { projectId = Supabase.Scalars.UUID.toString projectId
                            }
                    , query = Dict.empty
                    , hash = Nothing
                    }
                ]
            )

        FetchedUpdateFile projectId (Err httpError) ->
            ( { model | newProjectUpdatedFile = Just (GraphQL.Response.Failure httpError) }
            , Effect.none
            )


fetchDefaultBranchInfo :
    { projectId : Supabase.Scalars.UUID.UUID
    , owner : String
    , repo : Repo
    }
    -> Effect Msg
fetchDefaultBranchInfo props =
    let
        input : GitHub.Queries.DefaultBranchInfo.Input
        input =
            GitHub.Queries.DefaultBranchInfo.Input.new
                |> GitHub.Queries.DefaultBranchInfo.Input.owner props.owner
                |> GitHub.Queries.DefaultBranchInfo.Input.name props.repo.name
    in
    Effect.sendGitHubGraphQL
        { operation = GitHub.Queries.DefaultBranchInfo.new input
        , onResponse =
            FetchedDefaultBranchInfo
                { projectId = props.projectId
                , repo = props.repo
                }
        }


createNewJangleSettingsFile :
    { projectId : Supabase.Scalars.UUID.UUID
    , repo : Repo
    , branchId : GraphQL.Scalar.Id.Id
    , expectedHeadOid : GitHub.Scalars.GitObjectID.GitObjectID
    }
    -> Effect Msg
createNewJangleSettingsFile props =
    let
        settingsJsonContents : GitHub.Scalars.Base64String.Base64String
        settingsJsonContents =
            Jangle.Settings.new { title = props.repo.name }
                |> Jangle.Settings.encode
                |> Json.Encode.encode 2
                |> GitHub.Scalars.Base64String.fromString

        input : GitHub.Mutations.UpdateFile.Input
        input =
            GitHub.Mutations.UpdateFile.Input.new
                |> GitHub.Mutations.UpdateFile.Input.branchId props.branchId
                |> GitHub.Mutations.UpdateFile.Input.expectedHeadOid props.expectedHeadOid
                |> GitHub.Mutations.UpdateFile.Input.message "🐶 Jangle – Created project settings"
                |> GitHub.Mutations.UpdateFile.Input.path ".jangle/settings.json"
                |> GitHub.Mutations.UpdateFile.Input.contents settingsJsonContents
    in
    Effect.sendGitHubGraphQL
        { operation = GitHub.Mutations.UpdateFile.new input
        , onResponse = FetchedUpdateFile props.projectId
        }



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
        case model.projects of
            GraphQL.Response.Loading ->
                viewCentered
                    [ Components.EmptyState.viewLoading
                    ]

            GraphQL.Response.Success projects ->
                if List.isEmpty projects then
                    viewCreateFirstProject user model

                else
                    viewExistingProjects
                        { projects = projects
                        , user = user
                        , model = model
                        }

            GraphQL.Response.Failure httpError ->
                viewCentered
                    [ Components.EmptyState.viewHttpError httpError
                    ]
    }


viewCentered : List (Html Msg) -> List (Html Msg)
viewCentered contents =
    [ div [ Css.col, Css.align_center, Css.h_fill ] contents
    ]


viewExistingProjects :
    { projects : List Project
    , user : Auth.User
    , model : Model
    }
    -> List (Html Msg)
viewExistingProjects props =
    let
        toListItem : Project -> Components.ListItem.ListItem Msg
        toListItem project =
            let
                path : Route.Path.Path
                path =
                    Route.Path.Projects_ProjectId_
                        { projectId = Supabase.Scalars.UUID.toString project.id
                        }
            in
            Components.ListItem.new
                { icon = Components.Icon.GitHub
                , label = project.title
                }
                |> Components.ListItem.withHref (Route.Path.toString path)
    in
    [ div [ Css.col, Css.h_fill, Css.gap_16, Css.align_center ]
        [ div [ Css.col, Css.gap_4, Css.text_center ]
            [ h3 [ Css.font_title ] [ text "Select a project" ]
            , p [ Css.font_sublabel, Css.color_textSecondary ]
                [ text "Welcome back! Which project are you working on today?"
                ]
            ]
        , div [ Css.w_fill, Css.mw_320 ]
            [ Components.List.view
                { items = List.map toListItem props.projects
                }
            ]
        , Components.Button.new
            { label = "Create another project"
            }
            |> Components.Button.withOnClick ClickedCreateFirstProject
            |> Components.Button.view
        ]
    , viewCreateAProjectDialog props.user props.model
    ]


viewCreateFirstProject : Auth.User -> Model -> List (Html Msg)
viewCreateFirstProject user model =
    [ div [ Css.col, Css.fill, Css.align_center ]
        [ Components.EmptyState.viewCreateYourFirstProject
            { id = ids.createFirstProjectButton
            , onClick = ClickedCreateFirstProject
            }
        , div [ Css.h_96 ] []
        ]
    , viewCreateAProjectDialog user model
    ]


viewCreateAProjectDialog : Auth.User -> Model -> Html Msg
viewCreateAProjectDialog user model =
    Components.Dialog.new
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

        toListItem : Repo -> Maybe (Components.ListItem.ListItem Msg)
        toListItem repo =
            case repo.databaseId of
                Nothing ->
                    Nothing

                Just repoId ->
                    Components.ListItem.new
                        { icon = Components.Icon.GitHub
                        , label = repo.nameWithOwner
                        }
                        |> Components.ListItem.withOnClick
                            (SelectedRepoForNewProject
                                { repoId = repoId
                                , owner = githubInfo.username
                                , repo = repo
                                }
                            )
                        |> Just

        viewErrorWithTryAgainButton : Http.Error -> Html Msg
        viewErrorWithTryAgainButton httpError =
            div [ Css.col, Css.gap_16 ]
                [ Components.EmptyState.viewHttpError httpError
                , Components.Button.new { label = "Try again" }
                    |> Components.Button.withOnClick ClickedTryAgain
                    |> Components.Button.view
                ]

        viewOptionsOrRequestStatus : Html Msg
        viewOptionsOrRequestStatus =
            case model.newProject of
                Nothing ->
                    viewRepoOptions

                Just GraphQL.Response.Loading ->
                    Components.EmptyState.viewLoading

                Just (GraphQL.Response.Failure httpError) ->
                    viewErrorWithTryAgainButton httpError

                Just (GraphQL.Response.Success repos) ->
                    viewStatusOfBranchInfoRequest

        viewStatusOfBranchInfoRequest : Html Msg
        viewStatusOfBranchInfoRequest =
            case model.newProjectBranchInfo of
                Nothing ->
                    Components.EmptyState.viewLoading

                Just GraphQL.Response.Loading ->
                    Components.EmptyState.viewLoading

                Just (GraphQL.Response.Failure httpError) ->
                    viewErrorWithTryAgainButton httpError

                Just (GraphQL.Response.Success data) ->
                    viewStatusOfUpdateFileRequest

        viewStatusOfUpdateFileRequest : Html Msg
        viewStatusOfUpdateFileRequest =
            case model.newProjectUpdatedFile of
                Nothing ->
                    Components.EmptyState.viewLoading

                Just GraphQL.Response.Loading ->
                    Components.EmptyState.viewLoading

                Just (GraphQL.Response.Failure httpError) ->
                    viewErrorWithTryAgainButton httpError

                Just (GraphQL.Response.Success data) ->
                    Components.EmptyState.viewLoading
    in
    div [ Css.col, Css.gap_16 ]
        [ viewRepoNameSearchField
        , viewOptionsOrRequestStatus
        ]
