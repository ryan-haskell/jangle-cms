module Pages.Home_ exposing (..)

import Auth
import Components.Button
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
                Layouts.Sidebar
                    { title = "Dashboard"
                    , user = user
                    }
            )



-- INIT


type alias Model =
    { counter : Int
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { counter = 0 }
    , Effect.none
    )



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Effect.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
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
        [ div [ Css.col, Css.pad_32, Css.gap_16, Css.align_left ]
            [ h1 [ Css.font_h1 ] [ text ("Counter: " ++ String.fromInt model.counter) ]
            , div [ Css.row, Css.gap_8 ]
                [ Components.Button.new { label = "Increment" }
                    |> Components.Button.withOnClick Increment
                    |> Components.Button.view
                , Components.Button.new { label = "Decrement" }
                    |> Components.Button.withStyleSecondary
                    |> Components.Button.withOnClick Decrement
                    |> Components.Button.view
                ]
            ]
        ]
    }
