module Shared.Msg exposing (Msg(..))

import Http
import Supabase.Auth


type Msg
    = SupabaseUserApiResponded (Result Http.Error Supabase.Auth.User)
    | SignOut
