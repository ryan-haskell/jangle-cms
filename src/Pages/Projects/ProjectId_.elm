module Pages.Projects.ProjectId_ exposing (Model, Msg, page)

import Auth
import Components.Dialog
import Components.EmptyState
import Components.Icon
import Components.Layout
import Css
import Effect exposing (Effect)
import GraphQL.Response exposing (Response)
import Html exposing (..)
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Supabase.Queries.FindProject exposing (Project)
import Supabase.Queries.FindProject.Input
import Supabase.Scalars.UUID
import View exposing (View)


page :
    Auth.User
    -> Shared.Model
    -> Route { projectId : String }
    -> Page Model Msg
page user shared route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout
            (\_ ->
                Layouts.Sidebar
                    { title = "Dashboard"
                    , user = user
                    , projectId = route.params.projectId
                    }
            )



-- INIT


type alias Model =
    { project : Response Project
    }


init : Route { projectId : String } -> () -> ( Model, Effect Msg )
init route () =
    ( { project = GraphQL.Response.Loading }
    , let
        input : Supabase.Queries.FindProject.Input
        input =
            Supabase.Queries.FindProject.Input.new
                |> Supabase.Queries.FindProject.Input.id (Supabase.Scalars.UUID.fromString route.params.projectId)
      in
      Effect.sendSupabaseGraphQL
        { operation = Supabase.Queries.FindProject.new input
        , onResponse = FetchedProjectDetails
        }
    )



-- UPDATE


type Msg
    = ClickedCreateFirstContentType
    | FetchedProjectDetails (Result Http.Error Supabase.Queries.FindProject.Data)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedCreateFirstContentType ->
            ( model
            , Effect.showDialog
                { id = ids.createContentTypeDialog
                }
            )

        FetchedProjectDetails (Ok data) ->
            ( case toProject data of
                Just project ->
                    { model | project = GraphQL.Response.Success project }

                Nothing ->
                    { model | project = GraphQL.Response.Failure (Http.BadStatus 404) }
            , Effect.none
            )

        FetchedProjectDetails (Err httpError) ->
            ( { model | project = GraphQL.Response.Failure httpError }
            , Effect.none
            )


toProject : Supabase.Queries.FindProject.Data -> Maybe Project
toProject data =
    data.projects
        |> Maybe.map .edges
        |> Maybe.andThen List.head
        |> Maybe.map .node



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
    Model
    -> View Msg
view model =
    { title =
        case model.project of
            GraphQL.Response.Loading ->
                "Jangle"

            GraphQL.Response.Success project ->
                "Jangle • " ++ project.title

            GraphQL.Response.Failure _ ->
                "Jangle"
    , body =
        viewCreateYourFirstContentType model
    }


viewCreateYourFirstContentType : Model -> List (Html Msg)
viewCreateYourFirstContentType model =
    [ div
        [ Css.col
        , Css.fill
        , Css.w_fill
        , Css.pad_32
        , Css.align_center
        ]
        [ Components.EmptyState.viewCreateYourFirstContentType
            { id = ids.createContentTypeButton
            , onClick = ClickedCreateFirstContentType
            }
        ]
    , viewCreateContentTypeDialog model
    ]


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
