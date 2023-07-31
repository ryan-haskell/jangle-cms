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
    , expect : Http.Expect msg
    }
    -> Context
    -> Cmd msg
toHttpRequest props (Context context) =
    Http.request
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
        , expect = props.expect
        , timeout = context.timeout
        , tracker = context.tracker
        }
