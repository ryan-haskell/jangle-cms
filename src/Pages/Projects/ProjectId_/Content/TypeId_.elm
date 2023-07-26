module Pages.Projects.ProjectId_.Content.TypeId_ exposing (Model, Msg, page)

import Components.Icon
import Components.Layout
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route { projectId : String, typeId : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view route
        }



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


view : Route any -> Model -> View Msg
view route model =
    { title = "Pages.Projects.ProjectId_.Content.TypeId_"
    , body =
        [ Components.Layout.new
            { content =
                div [ Css.col, Css.pad_32, Css.gap_16, Css.align_left ]
                    [ text "Hello from the content page!"
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
