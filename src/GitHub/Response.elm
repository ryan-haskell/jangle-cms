module GitHub.Response exposing (Response(..), fromResult)

import Http


type Response data
    = Loading
    | Success data
    | Failure Http.Error


fromResult : Result Http.Error data -> Response data
fromResult result =
    case result of
        Ok data ->
            Success data

        Err httpError ->
            Failure httpError
