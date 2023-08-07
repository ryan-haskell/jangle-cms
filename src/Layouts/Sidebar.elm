module Layouts.Sidebar exposing (Model, Msg, Props, layout)

import Auth.User
import Components.Button
import Components.Dialog.UserSettings
import Components.Header
import Components.Icon
import Components.Layout
import Components.Sidebar
import Css
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias Props =
    { title : String
    , user : Auth.User.User
    , projectId : String
    }


layout :
    Props
    -> Shared.Model
    -> Route ()
    -> Layout () Model Msg contentMsg
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
    = ClickedUserControls
    | ClickedSignOut
    | ClickedSwitchProjects


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedUserControls ->
            ( model
            , Effect.showDialog
                { id = Components.Dialog.UserSettings.id
                }
            )

        ClickedSignOut ->
            ( model
            , Effect.signOut
            )

        ClickedSwitchProjects ->
            ( model
            , Effect.batch
                [ Effect.pushRoute
                    { path = Route.Path.Home_
                    , query = Dict.empty
                    , hash = Nothing
                    }
                , Effect.hideDialog
                    { id = Components.Dialog.UserSettings.id }
                ]
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Props -> Route () -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view props route { toContentMsg, model, content } =
    let
        header : Components.Header.Header contentMsg
        header =
            Components.Header.new
                { title = props.title
                }

        sidebar : Components.Sidebar.Sidebar contentMsg
        sidebar =
            Components.Sidebar.new
                { current = route.path
                , user = props.user
                , onUserControlsClick = toContentMsg ClickedUserControls
                , projectId = props.projectId
                , contentLinks = []
                }
    in
    { title = content.title
    , body =
        [ Components.Layout.new
            { content = content.body
            }
            |> Components.Layout.withHeader header
            |> Components.Layout.withSidebar sidebar
            |> Components.Layout.view
        , Components.Dialog.UserSettings.view
            { user = props.user
            , hasCurrentProject = True
            , onSignOutClick = toContentMsg ClickedSignOut
            , onSwitchProjectsClick = toContentMsg ClickedSwitchProjects
            }
        ]
    }
