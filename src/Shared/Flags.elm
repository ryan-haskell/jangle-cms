module Shared.Flags exposing (Flags, decoder)

import Json.Decode


type alias Flags =
    { supabase : Maybe SupabaseInfo
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.maybe supabaseInfoDecoder)


type alias SupabaseInfo =
    { apiKey : String
    , url : String
    }


supabaseInfoDecoder : Json.Decode.Decoder SupabaseInfo
supabaseInfoDecoder =
    Json.Decode.map2 SupabaseInfo
        (Json.Decode.at [ "env", "SUPABASE_KEY" ] Json.Decode.string)
        (Json.Decode.at [ "env", "SUPABASE_URL" ] Json.Decode.string)
