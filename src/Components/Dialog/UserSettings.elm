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


id : String
id =
    "dialog__user-settings"


view :
    { user : { user | name : String }
    , onSignOutClick : msg
    }
    -> Html msg
view props =
    Components.Dialog.new
        { title = "User settings"
        , content =
            [ div [ Css.col, Css.gap_16, Css.align_left ]
                [ Components.Button.new { label = "Sign out" }
                    |> Components.Button.withStyleSecondary
                    |> Components.Button.withOnClick props.onSignOutClick
                    |> Components.Button.withIcon Components.Icon.SignOut
                    |> Components.Button.view
                ]
            ]
        }
        |> Components.Dialog.withId id
        |> Components.Dialog.withSubtitle ("Signed in as " ++ props.user.name)
        |> Components.Dialog.view
