module Pages.Home_ exposing (..)

import Components.Button
import Components.Icon
import Components.Layout
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
        , view = view route
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


view : Route () -> Model -> View Msg
view route model =
    { title = "Homepage"
    , body =
        [ Components.Layout.new
            { content =
                div [ Css.col, Css.pad_32, Css.gap_16, Css.align_left ]
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
            }
            |> Components.Layout.withHeader { title = "Dashboard" }
            |> Components.Layout.withSidebar
                { current = route.path
                , user = { name = "Ryan Kelch", image = Just "https://media.licdn.com/dms/image/C5603AQEFyiIUdnt6xw/profile-displayphoto-shrink_200_200/0/1517588993682?e=1694649600&v=beta&t=ctfenv41CpIWdP_iAHui5vtMGNkWBfSSuPMqxS_q3E0" }
                , project = { id = "portfolio", name = "Portfolio Site" }
                , contentLinks =
                    [ { typeId = "blog-posts"
                      , icon = Components.Icon.Edit
                      , label = "Blog posts"
                      }
                    , { typeId = "contact-info"
                      , icon = Components.Icon.Page
                      , label = "Contact Info"
                      }
                    ]
                }
            |> Components.Layout.view
        ]
    }
