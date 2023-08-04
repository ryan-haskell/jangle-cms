module Supabase.Context exposing
    ( Context, create
    , withUserToken
    , toHttpRequest
    )

{-|

@docs Context, create
@docs withUserToken

@docs toHttpRequest, toUrl

-}

import Http
import Json.Decode
import Supabase.Request


type Context
    = Context
        { url : String
        , apiKey : String
        , userToken : Maybe String
        , timeout : Maybe Float
        , tracker : Maybe String
        }


create :
    { apiKey : String
    , url : String
    }
    -> Context
create props =
    Context
        { url = props.url
        , apiKey = props.apiKey
        , userToken = Nothing
        , timeout = Nothing
        , tracker = Nothing
        }


withUserToken : String -> Context -> Context
withUserToken userToken (Context context) =
    Context { context | userToken = Just userToken }


toHttpRequest :
    { method : String
    , endpoint : String
    , body : Http.Body
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
    -> Context
    -> Supabase.Request.Request value msg
toHttpRequest props (Context context) =
    { method = props.method
    , url = context.url ++ props.endpoint
    , headers =
        List.filterMap identity
            [ Just (Http.header "apikey" context.apiKey)
            , Just (Http.header "Content-Type" "application/json")
            , context.userToken
                |> Maybe.map
                    (\token -> Http.header "Authorization" ("Bearer " ++ token))
            ]
    , body = props.body
    , decoder = props.decoder
    , onResponse = props.onResponse
    , timeout = context.timeout
    , tracker = context.tracker
    }
