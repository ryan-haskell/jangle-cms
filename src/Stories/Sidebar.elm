module Stories.Sidebar exposing (main)

import Components.Icon exposing (Icon)
import Components.Sidebar
import Html exposing (Html)
import Route.Path
import Storybook.Component
import Storybook.Controls


type alias Controls =
    {}


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls


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
    Components.Sidebar.new
        { current = Route.Path.Home_
        , user =
            { image = Just "https://avatars.githubusercontent.com/u/6187256?v=4"
            , name = "Ryan Haskell-Glatz"
            , email = "ryan@jangle.io"
            }
        , onUserControlsClick = ClickedUserControls
        , project = { id = "jangle", name = "Jangle" }
        , contentLinks =
            [ { icon = Components.Icon.Page
              , label = "Homepage"
              , typeId = "homepage"
              }
            , { icon = Components.Icon.Edit
              , label = "Blog posts"
              , typeId = "blog-posts"
              }
            ]
        }
        |> Components.Sidebar.view
