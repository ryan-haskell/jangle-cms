module Shared.Model exposing (Model)

import Auth.User


type alias Model =
    { user : Maybe Auth.User.User
    }
