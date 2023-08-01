module Stories.Header exposing (main)

import Components.Header
import Components.UserControls
import Html exposing (Html)
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { title : String
    , hasUserControls : Bool
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withText { id = "title" }
        |> Storybook.Controls.withBoolean { id = "userControls" }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.simple
        { controls = decoder
        , view = view
        }


type Msg
    = ClickedUserControls



-- VIEW


view : Controls -> Html Msg
view controls =
    let
        withUserControls : Components.Header.Header Msg -> Components.Header.Header Msg
        withUserControls header =
            let
                userControls : Components.UserControls.UserControls Msg
                userControls =
                    Components.UserControls.new
                        { user =
                            { name = "Ryan Haskell-Glatz"
                            , email = "ryan@jangle.io"
                            , image = Just "https://avatars.githubusercontent.com/u/6187256?v=4"
                            }
                        }
                        |> Components.UserControls.withOnClick ClickedUserControls
            in
            if controls.hasUserControls then
                header
                    |> Components.Header.withUserControls userControls

            else
                header
    in
    Components.Header.new
        { title = controls.title
        }
        |> withUserControls
        |> Components.Header.view
