module Stories.Field exposing (main)

import Components.Field
import Components.Input
import Html exposing (Html)
import Json.Decode
import Storybook.Component
import Storybook.Controls
import String.Extra


type alias Controls =
    { withStyle : Maybe (Components.Input.Input Msg -> Components.Input.Input Msg)
    , withLabels : Maybe (String -> String -> Components.Field.Field Msg -> Components.Field.Field Msg)
    , error : String
    , label : String
    , sublabel : String
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withSelect
            { id = "style"
            , options =
                [ ( "Text"
                  , identity
                  )
                , ( "Search"
                  , Components.Input.withStyleSearch
                  )
                , ( "Multiline"
                  , Components.Input.withStyleMultiline
                  )
                ]
            }
        |> Storybook.Controls.withSelect
            { id = "labels"
            , options =
                [ ( "None"
                  , \_ _ field -> field
                  )
                , ( "Label"
                  , \label _ -> Components.Field.withLabel label
                  )
                , ( "LabelAndSublabel"
                  , \label sublabel ->
                        Components.Field.withLabelAndSublabel
                            { label = label
                            , sublabel = sublabel
                            }
                  )
                ]
            }
        |> Storybook.Controls.withText { id = "error" }
        |> Storybook.Controls.withText { id = "label" }
        |> Storybook.Controls.withText { id = "sublabel" }


main : Storybook.Component.Component Controls Model Msg
main =
    Storybook.Component.sandbox
        { controls = decoder
        , init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    { value : String }


init : Controls -> Model
init controls =
    { value = ""
    }



-- UPDATE


type Msg
    = ChangedInput String


update : Controls -> Msg -> Model -> Model
update controls msg model =
    case msg of
        ChangedInput text ->
            { model | value = text }



-- VIEW


view : Controls -> Model -> Html Msg
view controls model =
    let
        input : Components.Input.Input Msg
        input =
            Components.Input.new { value = model.value }
                |> Maybe.withDefault identity controls.withStyle
                |> Components.Input.withOnInput ChangedInput

        withLabels :
            Components.Field.Field Msg
            -> Components.Field.Field Msg
        withLabels field =
            case controls.withLabels of
                Just toLabels ->
                    field
                        |> toLabels controls.label controls.sublabel

                Nothing ->
                    field
    in
    Components.Field.new { input = input }
        |> Components.Field.withErrorMessage
            (String.Extra.nonBlank controls.error)
        |> withLabels
        |> Components.Field.view
