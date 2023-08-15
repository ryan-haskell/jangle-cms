module Stories.DragNDrop exposing (main)

import Components.DragNDrop
import Css
import Html exposing (..)
import Http
import Json.Decode
import Storybook.Component
import Storybook.Controls


type alias Controls =
    {}


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls


main : Storybook.Component.Component Controls Model Msg
main =
    Storybook.Component.sandbox
        { controls = decoder
        , init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Repo =
    { name : String
    }


type alias Model =
    { repos : List Repo
    }


init : Controls -> Model
init _ =
    { repos =
        [ Repo "Apple"
        , Repo "Banana"
        , Repo "Cherry"
        ]
    }



-- UPDATE


type Msg
    = SortedRepos (List Repo)


update : Controls -> Msg -> Model -> Model
update _ msg model =
    case msg of
        SortedRepos items ->
            { model | repos = items }



-- VIEW


view : Controls -> Model -> Html Msg
view controls model =
    div [ Css.w_240 ]
        [ Components.DragNDrop.view
            { onSort = SortedRepos
            , items = model.repos
            , viewItem = viewRepo
            }
        ]


viewRepo : Repo -> Html Msg
viewRepo item =
    span [ Css.font_sublabel ] [ text item.name ]
