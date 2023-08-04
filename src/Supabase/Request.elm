module Supabase.Request exposing (Request)

import Http
import Json.Decode


type alias Request value msg =
    { method : String
    , url : String
    , headers : List Http.Header
    , body : Http.Body
    , timeout : Maybe Float
    , tracker : Maybe String
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
