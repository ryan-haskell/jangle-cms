module Pages.Home_ exposing (..)

import Auth
import Components.Button
import Components.Dialog
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
        , view = view user
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
            , Effect.showDialog { id = ids.createProjectDialog }
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


ids :
    { createProjectDialog : String
    , createFirstProjectButton : String
    }
ids =
    { createProjectDialog = "dialog__create-project"
    , createFirstProjectButton = "button__create-first-project"
    }


view : Auth.User -> Model -> View Msg
view user model =
    { title = "Jangle | Dashboard"
    , body =
        [ div [ Css.col, Css.fill, Css.align_center ]
            [ Components.EmptyState.viewCreateYourFirstProject
                { id = ids.createFirstProjectButton
                , onClick = ClickedCreateFirstProject
                }
            , div [ Css.h_96 ] []
            ]
        , Components.Dialog.new
            { title = "Create a project"
            , content =
                [ div [ Css.col, Css.gap_16 ]
                    [ p [ Css.line_140 ]
                        [ text
                            ("👋 Hey ${name}! This form isn't quite ready yet..."
                                |> String.replace "${name}"
                                    (String.split " " user.name
                                        |> List.head
                                        |> Maybe.withDefault user.name
                                    )
                            )
                        ]
                    , p [ Css.line_140 ]
                        [ text "Try hitting the ESC key or clicking the \"X\" icon in the top-right corner!"
                        ]
                    ]
                ]
            }
            |> Components.Dialog.withSubtitle "Connect to an existing GitHub repository"
            |> Components.Dialog.withId ids.createProjectDialog
            |> Components.Dialog.view
        ]
    }
