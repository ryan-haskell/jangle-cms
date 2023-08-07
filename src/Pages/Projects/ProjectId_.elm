module Pages.Projects.ProjectId_ exposing (Model, Msg, page)

import Auth
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
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    Route { projectId : String }
    -> Model
    -> View Msg
view route model =
    { title = "Jangle | Project"
    , body =
        [ div [ Css.col, Css.pad_32, Css.gap_16, Css.align_left ]
            [ text "Hello from the project page!"
            ]
        ]
    }
