module Shared.Msg exposing (Msg(..))

import Http
import Json.Decode
import Supabase.Auth


type Msg
    = SupabaseUserApiResponded (Result Http.Error Supabase.Auth.User)
    | SignOut
    | SendJsonDecodeErrorToSentry
        { method : String
        , url : String
        , response : String
        , error : Json.Decode.Error
        }
    | SendHttpErrorToSentry
        { method : String
        , url : String
        , response : Maybe String
        , error : Http.Error
        }
