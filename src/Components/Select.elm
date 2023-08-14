module Components.Select exposing
    ( Select, new
    , withOnChange
    , withCreateNewOption
    , Model, init
    , toSelectedItem
    , Msg, update
    , view
    )

{-|

@docs Select, new
@docs withOnChange
@docs withCreateNewOption

@docs Model, init
@docs toSelectedItem

@docs Msg, update

@docs view

-}

import Browser.Dom
import Components.Icon
import Components.Input
import Css
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Attributes.Extra
import Html.Events
import Html.Extra
import Json.Decode
import String.Extra
import Task



-- NEW


type Select item msg
    = Select
        { id : String
        , model : Model item
        , toLabel : item -> String
        , toMsg : Msg item msg -> msg
        , onChange : Maybe (Maybe item -> msg)
        , fromLabel : Maybe (String -> item)
        }


new :
    { id : String
    , model : Model item
    , toLabel : item -> String
    , toMsg : Msg item msg -> msg
    }
    -> Select item msg
new props =
    Select
        { id = props.id
        , model = props.model
        , toLabel = props.toLabel
        , toMsg = props.toMsg
        , onChange = Nothing
        , fromLabel = Nothing
        }



-- MODIFIERS


withOnChange : (Maybe item -> msg) -> Select item msg -> Select item msg
withOnChange onChange (Select props) =
    Select { props | onChange = Just onChange }


withCreateNewOption :
    { fromLabel : String -> item }
    -> Select item msg
    -> Select item msg
withCreateNewOption options (Select props) =
    Select { props | fromLabel = Just options.fromLabel }



-- MODEL


type Model item
    = Model
        { selected : Maybe item
        , choices : List item
        , position : Position
        , search : String
        , menuSelectedIndex : Int
        }


type alias Position =
    { top : String
    , left : String
    , minWidth : String
    }


init :
    { selected : Maybe item
    , choices : List item
    }
    -> Model item
init props =
    Model
        { selected = props.selected
        , choices = props.choices
        , search = ""
        , position =
            { top = "unset"
            , left = "unset"
            , minWidth = "unset"
            }
        , menuSelectedIndex = 0
        }


toSelectedItem : Model item -> Maybe item
toSelectedItem (Model model) =
    model.selected



-- UPDATE


type Msg item msg
    = BeforeOpened
        { searchInputId : String
        , parent : BoundingClientRect
        }
    | SearchChanged String
    | FocusedSearchInput (Result Browser.Dom.Error ())
    | PressedArrowUp Int
    | PressedArrowDown Int
    | SelectedCreateOption
        { onChange : Maybe msg
        , popoverMenuId : String
        , newItem : item
        }
    | SelectedExistingOption
        { onChange : Maybe msg
        , popoverMenuId : String
        , item : item
        }
    | ChoiceFormSubmitted { popoverMenuId : String }


update :
    { msg : Msg item msg
    , model : Model item
    , toModel : Model item -> model
    , toMsg : Msg item msg -> msg
    }
    -> ( model, Effect msg )
update props =
    let
        (Model model) =
            props.model

        toModel model_ =
            Model model_
                |> props.toModel
    in
    case props.msg of
        BeforeOpened { searchInputId, parent } ->
            let
                position : Position
                position =
                    { top = toPx parent.bottom
                    , left = toPx parent.left
                    , minWidth = toPx parent.width
                    }
            in
            ( toModel
                { model
                    | position = position
                    , search = ""
                    , menuSelectedIndex = 0
                }
            , Effect.sendCmd
                (Browser.Dom.focus searchInputId
                    |> Task.attempt FocusedSearchInput
                    |> Cmd.map props.toMsg
                )
            )

        FocusedSearchInput result ->
            ( toModel model
            , Effect.none
            )

        SearchChanged value ->
            ( toModel
                { model
                    | search = value
                    , menuSelectedIndex = 0
                }
            , Effect.none
            )

        PressedArrowUp numberOfChoices ->
            cycleThroughOptions
                { props = props
                , offset = -1
                , numberOfChoices = numberOfChoices
                }

        PressedArrowDown numberOfChoices ->
            cycleThroughOptions
                { props = props
                , offset = 1
                , numberOfChoices = numberOfChoices
                }

        ChoiceFormSubmitted { popoverMenuId } ->
            ( toModel model
            , Effect.hidePopover
                { id = popoverMenuId
                }
            )

        SelectedCreateOption { onChange, popoverMenuId, newItem } ->
            ( toModel
                { model
                    | selected = Just newItem
                    , choices = model.choices ++ [ newItem ]
                }
            , Effect.batch
                [ Effect.hidePopover
                    { id = popoverMenuId
                    }
                , onChange
                    |> Maybe.map Effect.sendMsg
                    |> Maybe.withDefault Effect.none
                ]
            )

        SelectedExistingOption { onChange, popoverMenuId, item } ->
            ( toModel { model | selected = Just item }
            , Effect.batch
                [ Effect.hidePopover
                    { id = popoverMenuId
                    }
                , onChange
                    |> Maybe.map Effect.sendMsg
                    |> Maybe.withDefault Effect.none
                ]
            )


cycleThroughOptions :
    { props :
        { props
            | model : Model item
            , toModel : Model item -> model
            , toMsg : Msg item msg -> msg
        }
    , offset : Int
    , numberOfChoices : Int
    }
    -> ( model, Effect msg )
cycleThroughOptions { props, offset, numberOfChoices } =
    let
        (Model model) =
            props.model

        newIndex : Int
        newIndex =
            (model.menuSelectedIndex + offset)
                |> Basics.modBy numberOfChoices
    in
    ( { model | menuSelectedIndex = newIndex }
        |> Model
        |> props.toModel
    , Effect.none
    )



-- VIEW


type alias Choice item msg =
    { label : String
    , onSelect : Msg item msg
    }


view : Select item msg -> Html msg
view (Select props) =
    let
        (Model model) =
            props.model

        toggleId : String
        toggleId =
            props.id ++ "__toggle"

        searchInputId : String
        searchInputId =
            props.id ++ "__search"

        popoverMenuId : String
        popoverMenuId =
            props.id ++ "__menu"

        viewToggle : Html msg
        viewToggle =
            button
                [ Attr.id toggleId
                , Css.row
                , Css.gap_fill
                , Css.align_cy
                , Css.input
                , Css.border
                , Css.controls
                , Attr.attribute "popovertarget" popoverMenuId
                ]
                [ span []
                    [ Html.Extra.viewMaybe
                        (props.toLabel >> text)
                        model.selected
                    ]
                , Components.Icon.view16 Components.Icon.Down
                ]

        viewPopoverMenu : Html msg
        viewPopoverMenu =
            div
                [ Attr.id popoverMenuId
                , Attr.attribute "popover" ""
                , Html.Events.on "beforetoggle"
                    (beforeOpenDecoder
                        { searchInputId = searchInputId
                        }
                        |> Json.Decode.map props.toMsg
                    )
                , Attr.style "top" model.position.top
                , Attr.style "left" model.position.left
                , Attr.style "min-width" model.position.minWidth
                , Css.padTop_8
                ]
                [ form
                    [ Html.Events.onSubmit
                        (ChoiceFormSubmitted
                            { popoverMenuId = popoverMenuId
                            }
                            |> props.toMsg
                        )
                    , Css.col
                    , Css.border
                    , Css.radius_8
                    , Css.bg_background
                    , Css.overflow_hidden
                    ]
                    [ viewSearchField
                    , viewDivider
                    , viewSearchResults
                    ]
                ]

        viewDivider : Html msg
        viewDivider =
            div [ Css.borderBottom, Css.row ] []

        viewSearchField : Html msg
        viewSearchField =
            let
                arrowKeyDecoder : Json.Decode.Decoder msg
                arrowKeyDecoder =
                    let
                        fromCodeToMsg : String -> Json.Decode.Decoder (Msg item msg)
                        fromCodeToMsg code =
                            case code of
                                "ArrowUp" ->
                                    Json.Decode.succeed (PressedArrowUp numberOfChoices)

                                "ArrowDown" ->
                                    Json.Decode.succeed (PressedArrowDown numberOfChoices)

                                _ ->
                                    Json.Decode.fail ("Ignoring key: " ++ code)
                    in
                    Json.Decode.field "code" Json.Decode.string
                        |> Json.Decode.andThen fromCodeToMsg
                        |> Json.Decode.map props.toMsg
            in
            input
                [ Attr.value model.search
                , Html.Events.onInput (SearchChanged >> props.toMsg)
                , Attr.id searchInputId
                , Css.input
                , Css.w_fill
                , Css.input__no_focus
                , Css.font_sublabel
                , Attr.autocomplete False
                , Html.Events.on "keydown" arrowKeyDecoder
                ]
                []

        canCreateNewOption : Bool
        canCreateNewOption =
            props.fromLabel /= Nothing

        viewSearchResults : Html msg
        viewSearchResults =
            div [ Css.col ]
                [ if canCreateNewOption then
                    viewMenuHint "Select an option or create one"

                  else
                    viewMenuHint "Select an option below"
                , viewChoices
                ]

        viewMenuHint : String -> Html msg
        viewMenuHint hint =
            span
                [ Css.color_textSecondary
                , Css.font_sublabel
                , Css.h_32
                , Css.pad_16
                , Css.col
                , Css.align_cy
                ]
                [ text hint ]

        isSelected : Int -> Bool
        isSelected index =
            index == model.menuSelectedIndex

        viewChoice : Int -> Choice item msg -> Html msg
        viewChoice index choice =
            button
                [ Css.row
                , Css.align_cy
                , Css.font_sublabel
                , Html.Events.onClick (props.toMsg choice.onSelect)
                , Css.popover_choice
                , if isSelected index then
                    Css.popover_choice__selected

                  else
                    Html.Attributes.Extra.empty
                , if isSelected index then
                    Attr.type_ "submit"

                  else
                    Attr.type_ "button"
                , Css.h_32
                , Css.padX_12
                ]
                [ text choice.label
                ]

        toCreateNewOptionChoice : List (Choice item msg)
        toCreateNewOptionChoice =
            case props.fromLabel of
                Nothing ->
                    []

                Just fromLabel ->
                    if
                        String.Extra.isBlank model.search
                            || List.any ((==) model.search) (List.map props.toLabel model.choices)
                    then
                        []

                    else
                        let
                            newItem : item
                            newItem =
                                fromLabel model.search
                        in
                        [ { label =
                                "Create \"${search}\""
                                    |> String.replace "${search}" model.search
                          , onSelect =
                                SelectedCreateOption
                                    { popoverMenuId = popoverMenuId
                                    , newItem = newItem
                                    , onChange =
                                        case props.onChange of
                                            Just onChange ->
                                                Just (onChange (Just newItem))

                                            Nothing ->
                                                Nothing
                                    }
                          }
                        ]

        toExistingChoicesMatchingQuery : List (Choice item msg)
        toExistingChoicesMatchingQuery =
            model.choices
                |> List.filter
                    (\item ->
                        String.contains
                            (String.toLower model.search)
                            (String.toLower (props.toLabel item))
                    )
                |> List.map
                    (\item ->
                        { label = props.toLabel item
                        , onSelect =
                            SelectedExistingOption
                                { popoverMenuId = popoverMenuId
                                , item = item
                                , onChange =
                                    case props.onChange of
                                        Just onChange ->
                                            Just (onChange (Just item))

                                        Nothing ->
                                            Nothing
                                }
                        }
                    )

        renderedChoices : List (Choice item msg)
        renderedChoices =
            List.concat
                [ toExistingChoicesMatchingQuery
                , if canCreateNewOption then
                    toCreateNewOptionChoice

                  else
                    []
                ]

        numberOfChoices : Int
        numberOfChoices =
            List.length renderedChoices

        viewChoices : Html msg
        viewChoices =
            if List.isEmpty renderedChoices then
                Html.Extra.nothing

            else
                div
                    [ Css.col
                    , Css.popover_choice__list
                    ]
                    (viewDivider
                        :: (renderedChoices
                                |> List.indexedMap viewChoice
                                |> List.intersperse viewDivider
                           )
                    )
    in
    div []
        [ viewToggle
        , viewPopoverMenu
        ]


beforeOpenDecoder :
    { searchInputId : String
    }
    -> Json.Decode.Decoder (Msg item msg)
beforeOpenDecoder props =
    Json.Decode.field "newState" Json.Decode.string
        |> Json.Decode.andThen
            (\newState ->
                if newState == "open" then
                    Json.Decode.map
                        (\parent ->
                            BeforeOpened
                                { searchInputId = props.searchInputId
                                , parent = parent
                                }
                        )
                        (Json.Decode.at
                            [ "target", "parentNode", "___getBoundingClientRect" ]
                            boundingClientRectDecoder
                        )

                else
                    Json.Decode.fail "Not opening"
            )



-- BOUNDING CLIENT RECT


type alias BoundingClientRect =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , top : Float
    , left : Float
    , right : Float
    , bottom : Float
    }


boundingClientRectDecoder : Json.Decode.Decoder BoundingClientRect
boundingClientRectDecoder =
    Json.Decode.map8 BoundingClientRect
        (Json.Decode.field "x" Json.Decode.float)
        (Json.Decode.field "y" Json.Decode.float)
        (Json.Decode.field "width" Json.Decode.float)
        (Json.Decode.field "height" Json.Decode.float)
        (Json.Decode.field "top" Json.Decode.float)
        (Json.Decode.field "left" Json.Decode.float)
        (Json.Decode.field "right" Json.Decode.float)
        (Json.Decode.field "bottom" Json.Decode.float)


toPx : Float -> String
toPx px =
    String.fromFloat px ++ "px"
