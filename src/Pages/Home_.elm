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
import Effect exposing (Effect)
import GitHub.Queries.RecentRepos
import GitHub.Queries.RecentRepos.Input
import GitHub.Queries.SearchRepos
import GitHub.Queries.SearchRepos.Input
import GitHub.Queries.SearchRepos.SearchResultItem as SearchResultItem
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
import String.Extra
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
    , recentRepos : GitHub.Response.Response (List Repo)
    , searchRepos : Maybe (GitHub.Response.Response (List Repo))
    }


type alias Repo =
    GitHub.Queries.RecentRepos.Repository


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { searchQuery = ""
      , recentRepos = GitHub.Response.Loading
      , searchRepos = Nothing
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
            -- TODO: Report to Sentry
            Effect.none
    )



-- UPDATE


type Msg
    = ClickedCreateFirstProject
    | ChangedSearchValue Auth.User.GitHubInfo String
    | SelectedRepo Repo
    | ThrottledSearchRepos { username : String, searchQuery : String }
    | FetchedRecentRepos String (Result Http.Error GitHub.Queries.RecentRepos.Data)
    | FetchedSearchRepos (Result Http.Error GitHub.Queries.SearchRepos.Data)


update : Auth.User -> Msg -> Model -> ( Model, Effect Msg )
update user msg model =
    case msg of
        ClickedCreateFirstProject ->
            ( { model | searchQuery = "" }
            , Effect.showDialog { id = ids.createProjectDialog }
            )

        ChangedSearchValue { username } searchQuery ->
            ( { model
                | searchQuery = searchQuery
                , searchRepos = Just GitHub.Response.Loading
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

        SelectedRepo repo ->
            ( model
            , Effect.none
            )

        FetchedRecentRepos username (Ok data) ->
            ( { model
                | recentRepos =
                    case data.user of
                        Nothing ->
                            ("Couldn't find user: " ++ username)
                                |> Http.BadBody
                                |> GitHub.Response.Failure

                        Just user_ ->
                            user_.repositories
                                |> GitHub.Relay.toNodes
                                |> GitHub.Response.Success
              }
            , Effect.none
              -- TODO: Report to Sentry
            )

        FetchedRecentRepos username (Err httpError) ->
            ( { model | recentRepos = GitHub.Response.Failure httpError }
            , Effect.none
              -- TODO: Report to Sentry
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
                    GitHub.Relay.toNodes data.search
                        |> List.filterMap toRepo
                        |> GitHub.Response.Success
                        |> Just
              }
            , Effect.none
            )

        FetchedSearchRepos (Err httpError) ->
            ( { model
                | searchRepos =
                    httpError
                        |> GitHub.Response.Failure
                        |> Just
              }
            , -- TODO: Report to Sentry
              Effect.none
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
    div [ Css.col, Css.gap_16 ]
        [ Components.Field.new
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
        , if String.isEmpty model.searchQuery then
            case model.recentRepos of
                GitHub.Response.Loading ->
                    Components.EmptyState.viewLoading

                GitHub.Response.Failure httpError ->
                    Components.EmptyState.viewHttpError httpError

                GitHub.Response.Success repos ->
                    Components.List.view { items = List.map toListItem repos }

          else
            case model.searchRepos of
                Nothing ->
                    Components.EmptyState.viewLoading

                Just GitHub.Response.Loading ->
                    Components.EmptyState.viewLoading

                Just (GitHub.Response.Failure httpError) ->
                    Components.EmptyState.viewHttpError httpError

                Just (GitHub.Response.Success repos) ->
                    if List.isEmpty repos then
                        Components.EmptyState.viewNoResultsFound
                            "No repositories found matching your search"

                    else
                        Components.List.view { items = List.map toListItem repos }
        ]


toListItem : Repo -> Components.List.Item Msg
toListItem repo =
    { icon = Components.Icon.GitHub
    , label = repo.nameWithOwner
    , onClick = SelectedRepo repo
    }
