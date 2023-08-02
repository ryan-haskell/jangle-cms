module Components.Sidebar exposing
    ( Sidebar, new
    , view
    )

{-|

@docs Sidebar, new
@docs view

-}

import Components.Icon exposing (Icon)
import Components.JangleLogo
import Components.SidebarLink exposing (SidebarLink)
import Components.SidebarLinkGroup
import Components.UserControls
import Css
import Html exposing (..)
import Route.Path exposing (Path)


type Sidebar msg
    = Sidebar
        { current : Path
        , user :
            { name : String
            , email : String
            , image : Maybe String
            }
        , project : { id : String, name : String }
        , onUserControlsClick : msg
        , contentLinks :
            List
                { icon : Icon
                , label : String
                , typeId : String
                }
        }


new :
    { current : Path
    , user :
        { user
            | name : String
            , email : String
            , image : Maybe String
        }
    , onUserControlsClick : msg
    , project : { id : String, name : String }
    , contentLinks :
        List
            { icon : Icon
            , label : String
            , typeId : String
            }
    }
    -> Sidebar msg
new props =
    Sidebar
        { current = props.current
        , project = props.project
        , contentLinks = props.contentLinks
        , onUserControlsClick = props.onUserControlsClick
        , user =
            { name = props.user.name
            , email = props.user.email
            , image = props.user.image
            }
        }


view : Sidebar msg -> Html msg
view (Sidebar props) =
    let
        viewHeaderBrand : Html msg
        viewHeaderBrand =
            div
                [ Css.row
                , Css.align_center
                , Css.h_96
                , Css.shrink_none
                ]
                [ Components.JangleLogo.viewSmall ]

        viewTopLinks : Html msg
        viewTopLinks =
            div [ Css.col, Css.gap_16, Css.scroll ]
                [ Components.SidebarLink.new
                    { icon = Components.Icon.Home
                    , label = "Dashboard"
                    }
                    |> Components.SidebarLink.withRoutePath Route.Path.Home_
                    |> Components.SidebarLink.withSelectedStyle (Route.Path.Home_ == props.current)
                    |> Components.SidebarLink.view
                , Components.SidebarLinkGroup.view
                    { title = "Content"
                    , links = List.map viewContentLink props.contentLinks
                    }
                ]

        viewContentLink : ContentLink -> SidebarLink
        viewContentLink link =
            let
                routePath : Path
                routePath =
                    Route.Path.Projects_ProjectId__Content_TypeId_
                        { projectId = props.project.id
                        , typeId = link.typeId
                        }
            in
            Components.SidebarLink.new
                { icon = link.icon
                , label = link.label
                }
                |> Components.SidebarLink.withRoutePath routePath
                |> Components.SidebarLink.withSelectedStyle (routePath == props.current)
    in
    aside
        [ Css.col
        , Css.w_240
        , Css.h_fill
        , Css.overflow_hidden
        , Css.bg_navbar
        , Css.borderRight
        ]
        [ div [ Css.col, Css.fill, Css.scroll ]
            [ viewHeaderBrand
            , viewTopLinks
            ]
        , div [ Css.shrink_none, Css.row, Css.pad_16, Css.overflow_hidden ]
            [ Components.UserControls.new { user = props.user }
                |> Components.UserControls.withOnClick props.onUserControlsClick
                |> Components.UserControls.withWidthFill
                |> Components.UserControls.view
            ]
        ]


type alias ContentLink =
    { icon : Icon
    , label : String
    , typeId : String
    }
