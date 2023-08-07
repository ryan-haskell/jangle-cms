module Layouts.Header exposing (Model, Msg, Props, layout)

import Auth.User
import Components.Button
import Components.Dialog.UserSettings
import Components.Header
import Components.Icon
import Components.Layout
import Components.UserControls
import Css
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (..)
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path
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
                |> Components.Header.withUserControls userControls

        userControls : Components.UserControls.UserControls contentMsg
        userControls =
            Components.UserControls.new
                { user = props.user
                }
                |> Components.UserControls.withOnClick (toContentMsg ClickedUserControls)
    in
    { title = content.title
    , body =
        [ Components.Layout.new
            { content = content.body
            }
            |> Components.Layout.withHeader header
            |> Components.Layout.view
        , Components.Dialog.UserSettings.view
            { user = props.user
            , hasCurrentProject = False
            , onSignOutClick = toContentMsg ClickedSignOut
            , onSwitchProjectsClick = toContentMsg ClickedSwitchProjects
            }
        ]
    }
