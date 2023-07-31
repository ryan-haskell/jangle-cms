module Layouts.Sidebar exposing (Model, Msg, Props, layout)

import Auth.User
import Components.Button
import Components.Icon
import Components.Layout
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Props =
    { title : String
    , user : Auth.User.User
    }


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view props route
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Props -> Route () -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view props route { toContentMsg, model, content } =
    { title = content.title
    , body =
        [ Components.Layout.new
            { content = Html.div [ class "page" ] content.body
            }
            |> Components.Layout.withHeader { title = props.title }
            |> Components.Layout.withSidebar
                { current = route.path
                , user = props.user
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
