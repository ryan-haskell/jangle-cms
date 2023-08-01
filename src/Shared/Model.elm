module Shared.Model exposing (Model)

import Auth.User
import Shared.Flags


type alias Model =
    { flags : Shared.Flags.Flags
    , user : Auth.User.SignInStatus
    }
