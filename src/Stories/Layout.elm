module Stories.Layout exposing (main)

import Components.Icon exposing (Icon)
import Components.Layout
import Css
import Html exposing (..)
import Html.Attributes
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
    Storybook.Component.new
        { controls = decoder
        , view = view
        }


type Msg
    = NoOp



-- VIEW


view : Controls -> Html Msg
view controls =
    Components.Layout.new
        { content =
            div
                [ Css.pad_32
                , Css.color_textSecondary
                , Html.Attributes.style "min-height" "1000vh"
                ]
                [ text "✨ Page content goes here" ]
        }
        |> Components.Layout.withHeader
            { title = "Dashboard"
            }
        |> Components.Layout.withSidebar
            { current = Route.Path.Home_
            , user =
                { image = Just "https://avatars.githubusercontent.com/u/6187256?v=4"
                , name = "Ryan Haskell-Glatz"
                }
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
        |> Components.Layout.view
