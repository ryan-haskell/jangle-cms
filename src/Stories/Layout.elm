module Stories.Layout exposing (main)

import Components.Header
import Components.Icon exposing (Icon)
import Components.Layout
import Components.Sidebar
import Components.UserControls
import Css
import Html exposing (..)
import Html.Attributes
import Route.Path
import Storybook.Component
import Storybook.Controls


type alias Controls =
    { hasSidebar : Bool
    , hasHeader : Bool
    }


decoder : Storybook.Controls.Decoder Controls
decoder =
    Storybook.Controls.new Controls
        |> Storybook.Controls.withBoolean { id = "sidebar" }
        |> Storybook.Controls.withBoolean { id = "header" }


main : Storybook.Component.Component Controls () Msg
main =
    Storybook.Component.new
        { controls = decoder
        , view = view
        }


type Msg
    = ClickedUserControls



-- VIEW


view : Controls -> Html Msg
view controls =
    let
        user =
            { name = "Ryan Haskell-Glatz"
            , email = "ryan@jangle.io"
            , image = Just "https://avatars.githubusercontent.com/u/6187256?v=4"
            }

        withHeader : Components.Layout.Layout Msg -> Components.Layout.Layout Msg
        withHeader layout =
            let
                header : Components.Header.Header Msg
                header =
                    Components.Header.new
                        { title = "Dashboard"
                        }
            in
            if controls.hasHeader then
                layout
                    |> Components.Layout.withHeader
                        (header
                            |> (if controls.hasSidebar then
                                    identity

                                else
                                    Components.Header.withUserControls
                                        (Components.UserControls.new { user = user }
                                            |> Components.UserControls.withOnClick ClickedUserControls
                                        )
                               )
                        )

            else
                layout

        withSidebar : Components.Layout.Layout Msg -> Components.Layout.Layout Msg
        withSidebar layout =
            let
                sidebar : Components.Sidebar.Sidebar Msg
                sidebar =
                    Components.Sidebar.new
                        { current = Route.Path.Home_
                        , user = user
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
            in
            if controls.hasSidebar then
                layout
                    |> Components.Layout.withSidebar sidebar

            else
                layout
    in
    Components.Layout.new
        { content =
            [ div
                [ Css.pad_32
                , Css.color_textSecondary
                , Html.Attributes.style "min-height" "1000vh"
                ]
                [ text "✨ Page content goes here" ]
            ]
        }
        |> withHeader
        |> withSidebar
        |> Components.Layout.view
