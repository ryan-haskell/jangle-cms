module Components.DragNDrop exposing (view)

import Components.Icon
import Css
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events
import Json.Decode
import List.Extra


view :
    { items : List item
    , viewItem : item -> Html msg
    , onSort : List item -> msg
    }
    -> Html msg
view props =
    let
        viewDraggableItem : item -> Html msg
        viewDraggableItem item =
            div
                [ Attr.attribute "draggable-item" ""
                , Css.row
                , Css.bg_background
                , Css.align_cy
                , Css.gap_8
                , Css.pad_4
                , Css.w_fill
                ]
                [ div
                    [ Attr.attribute "draggable-handle" ""
                    , Css.font_sublabel
                    , Css.pad_4
                    , Css.radius_circle
                    , Css.controls
                    , Css.col
                    ]
                    [ Components.Icon.view16 Components.Icon.Handle ]
                , props.viewItem item
                ]
    in
    div [ Css.col, Css.w_fill ]
        [ node "drag-n-drop"
            [ Html.Events.on "sort"
                (Json.Decode.map2 (reorderByIndex props.items)
                    (Json.Decode.at [ "detail", "oldIndex" ] Json.Decode.int)
                    (Json.Decode.at [ "detail", "newIndex" ] Json.Decode.int)
                    |> Json.Decode.map props.onSort
                )
            , Attr.style "display" "none"
            ]
            []
        , div
            [ Attr.attribute "draggable-parent" ""
            , Css.col
            , Css.gap_1
            , Css.bg_border
            , Css.border
            , Css.w_fill
            ]
            (List.map viewDraggableItem props.items)
        ]


reorderByIndex : List a -> Int -> Int -> List a
reorderByIndex list oldIndex newIndex =
    let
        beforeOldIndex : List a
        beforeOldIndex =
            List.take oldIndex list

        afterOldIndex : List a
        afterOldIndex =
            List.drop (oldIndex + 1) list

        listWithItemRemoved : List a
        listWithItemRemoved =
            beforeOldIndex ++ afterOldIndex
    in
    case List.Extra.getAt oldIndex list of
        Just item ->
            let
                ( start, end ) =
                    List.Extra.splitAt newIndex listWithItemRemoved
            in
            start ++ [ item ] ++ end

        Nothing ->
            list
