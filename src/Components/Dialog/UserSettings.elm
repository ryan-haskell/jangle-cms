module Components.Dialog.UserSettings exposing
    ( view
    , id
    )

{-| This dialog was intended to be used in both `Layouts.Sidebar`
and `Layouts.Header`, so we created a module for it here.

@docs view
@docs id

-}

import Components.Button
import Components.Dialog
import Components.Icon
import Css
import Html exposing (..)
import Html.Extra
import Route.Path


id : String
id =
    "dialog__user-settings"


view :
    { user : { user | name : String }
    , hasCurrentProject : Bool
    , onSignOutClick : msg
    , onSwitchProjectsClick : msg
    }
    -> Html msg
view props =
    let
        viewSwitchProjectsButton : Html msg
        viewSwitchProjectsButton =
            Components.Button.new { label = "Switch projects" }
                |> Components.Button.withStyleSecondary
                |> Components.Button.withOnClick props.onSwitchProjectsClick
                |> Components.Button.withIcon Components.Icon.Switch
                |> Components.Button.view

        viewSignOutButton : Html msg
        viewSignOutButton =
            Components.Button.new { label = "Sign out" }
                |> Components.Button.withStyleSecondary
                |> Components.Button.withOnClick props.onSignOutClick
                |> Components.Button.withIcon Components.Icon.SignOut
                |> Components.Button.view
    in
    Components.Dialog.new
        { title = "User settings"
        , content =
            [ div [ Css.col, Css.gap_16, Css.align_center, Css.pad_32 ]
                [ Html.Extra.viewIf
                    props.hasCurrentProject
                    viewSwitchProjectsButton
                , viewSignOutButton
                ]
            ]
        }
        |> Components.Dialog.withId id
        |> Components.Dialog.withSubtitle ("Signed in as " ++ props.user.name)
        |> Components.Dialog.view
