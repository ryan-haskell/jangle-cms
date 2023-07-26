module Components.Sidebar exposing (view)

import Components.Avatar
import Components.Icon exposing (Icon)
import Components.JangleLogo
import Components.SidebarLink exposing (SidebarLink)
import Components.SidebarLinkGroup
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Route.Path exposing (Path)


view :
    { current : Path
    , user :
        { user
            | name : String
            , image : Maybe String
        }
    , project : { id : String, name : String }
    , contentLinks :
        List
            { icon : Icon
            , label : String
            , typeId : String
            }
    }
    -> Html msg
view props =
    let
        viewHeaderBrand =
            div
                [ Css.row
                , Css.align_center
                , Css.h_96
                , Css.shrink_none
                ]
                [ Components.JangleLogo.viewSmall ]

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
            Components.SidebarLink.new
                { icon = link.icon
                , label = link.label
                }
                |> Components.SidebarLink.withRoutePath
                    (Route.Path.Projects_ProjectId__Content_TypeId_
                        { projectId = props.project.id
                        , typeId = link.typeId
                        }
                    )
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
            [ Components.Avatar.view
                { name = props.user.name
                , image = props.user.image
                , project = props.project.name
                }
            ]
        ]


type alias ContentLink =
    { icon : Icon
    , label : String
    , typeId : String
    }
