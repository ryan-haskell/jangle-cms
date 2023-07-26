module Components.Layout exposing
    ( Layout, new
    , withHeader, withSidebar
    , view
    )

{-|

@docs Layout, new
@docs withHeader, withSidebar
@docs view

-}

import Components.Header
import Components.Icon exposing (Icon)
import Components.Sidebar
import Css
import Html exposing (..)
import Route.Path exposing (Path)


type Layout msg
    = Layout
        { content : Html msg
        , header : Maybe { title : String }
        , sidebar :
            Maybe
                { current : Path
                , user :
                    { name : String
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
        }


new : { content : Html msg } -> Layout msg
new props =
    Layout
        { content = props.content
        , header = Nothing
        , sidebar = Nothing
        }


withHeader :
    { title : String
    }
    -> Layout msg
    -> Layout msg
withHeader header (Layout props) =
    Layout { props | header = Just header }


withSidebar :
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
    -> Layout msg
    -> Layout msg
withSidebar sidebar (Layout props) =
    Layout
        { props
            | sidebar =
                Just
                    { current = sidebar.current
                    , user =
                        { name = sidebar.user.name
                        , image = sidebar.user.image
                        }
                    , project = sidebar.project
                    , contentLinks = sidebar.contentLinks
                    }
        }


view : Layout msg -> Html msg
view (Layout props) =
    div [ Css.row, Css.h_fill, Css.shrink_none ]
        [ case props.sidebar of
            Just sidebar ->
                Components.Sidebar.view sidebar

            Nothing ->
                text ""
        , main_ [ Css.fill, Css.scroll ]
            [ case props.header of
                Just header ->
                    Components.Header.view header

                Nothing ->
                    text ""
            , props.content
            ]
        ]
