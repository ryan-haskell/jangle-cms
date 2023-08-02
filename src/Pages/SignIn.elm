module Pages.SignIn exposing (Model, Msg, page)

import Components.Button
import Components.Icon
import Components.JangleLogo
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Supabase.Auth
import Url
import Url.Builder
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
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
    = UserClickedSignIn


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserClickedSignIn ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Jangle | Sign in"
    , body =
        [ div [ Css.h_fill, Css.col, Css.align_center, Css.gap_16 ]
            [ Components.JangleLogo.viewLarge
            , Components.Button.new { label = "Sign in with GitHub" }
                |> Components.Button.withStyleSecondary
                |> Components.Button.withIcon Components.Icon.GitHub
                |> Components.Button.withHref
                    (Supabase.Auth.toGitHubOAuthUrl
                        { redirectTo = shared.flags.baseUrl
                        , supabaseUrl = shared.flags.supabase.url
                        , scopes = []
                        }
                    )
                |> Components.Button.view
            ]
        ]
    }
