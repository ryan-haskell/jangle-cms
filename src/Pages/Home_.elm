module Pages.Home_ exposing (..)

import Components.Button
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



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


view : Model -> View Msg
view model =
    { title = "Homepage"
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
