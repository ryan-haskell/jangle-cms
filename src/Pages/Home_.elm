module Pages.Home_ exposing (..)

import Auth
import Components.Button
import Components.EmptyState
import Components.Icon
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
        , view = view route.path
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
    { isDialogOpen : Bool
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { isDialogOpen = False }
    , Effect.none
    )



-- UPDATE


type Msg
    = ClickedCreateFirstProject


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedCreateFirstProject ->
            ( { model | isDialogOpen = True }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Path -> Model -> View Msg
view path model =
    { title = "Jangle | Dashboard"
    , body =
        [ div [ Css.col, Css.fill, Css.align_center ]
            [ Components.EmptyState.viewCreateYourFirstProject
                { onClick = ClickedCreateFirstProject
                }
            , div [ Css.h_96 ] []
            ]
        ]
    }
