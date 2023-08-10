module Stories.Select exposing (main)

import Components.Button
import Components.Select
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { variant : Maybe Variant
    }


type Variant
    = CreateAProject


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "variant"
            , options =
                [ ( "CreateAProject", CreateAProject )
                ]
            }


main : Storybook.Component.Component Controls Model Msg
main =
    Storybook.Component.new
        { controls = decoder
        , init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Item =
    String


type alias Model =
    { select : Components.Select.Model Item
    }


init : Controls -> ( Model, Effect Msg )
init controls =
    ( { select =
            Components.Select.init
                { selected = Nothing
                , choices =
                    [ "Development"
                    , "Production"
                    , "Unknown"
                    ]
                }
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = SelectSent (Components.Select.Msg Item Msg)
    | SelectedChoice (Maybe Item)


update : Controls -> Msg -> Model -> ( Model, Effect Msg )
update controls msg model =
    case msg of
        SelectSent innerMsg ->
            Components.Select.update
                { msg = innerMsg
                , model = model.select
                , toModel = \select -> { model | select = select }
                , toMsg = SelectSent
                }

        SelectedChoice maybeItem ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Controls -> Model -> Sub Msg
subscriptions controls model =
    Sub.none



-- VIEW


view : Controls -> Model -> Html Msg
view controls model =
    Components.Select.new
        { id = "select__demo"
        , model = model.select
        , toLabel = identity
        , fromLabel = identity
        , toMsg = SelectSent
        }
        |> Components.Select.withOnChange SelectedChoice
        |> Components.Select.view
