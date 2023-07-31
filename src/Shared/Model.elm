module Shared.Model exposing (Model)

import Auth.User
import Shared.Flags


type alias Model =
    { supabase : Shared.Flags.SupabaseInfo
    , user : Auth.User.SignInStatus
    }
