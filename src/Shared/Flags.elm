module Shared.Flags exposing
    ( Flags
    , SupabaseInfo
    , decoder
    )

import Json.Decode
import Supabase.OAuthResponse


type alias Flags =
    { baseUrl : String
    , supabase : SupabaseInfo
    , cachedOAuthResponse : Maybe Supabase.OAuthResponse.OAuthResponse
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map3 Flags
        (Json.Decode.field "baseUrl" Json.Decode.string)
        supabaseInfoDecoder
        (Json.Decode.maybe (Json.Decode.field "oAuthResponse" Supabase.OAuthResponse.decoder))


type alias SupabaseInfo =
    { apiKey : String
    , url : String
    }


supabaseInfoDecoder : Json.Decode.Decoder SupabaseInfo
supabaseInfoDecoder =
    Json.Decode.map2 SupabaseInfo
        (Json.Decode.at [ "env", "SUPABASE_KEY" ] Json.Decode.string)
        (Json.Decode.at [ "env", "SUPABASE_URL" ] Json.Decode.string)
