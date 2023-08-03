module Tests.Mock exposing (user)

import Auth.User


user : Auth.User.User
user =
    { id = "123"
    , name = "Ryan Haskell-Glatz"
    , email = "ryan@jangle.io"
    , image = Nothing
    , supabaseToken = "supabase_123"
    , github =
        Just
            { token = "github_123"
            , username = "ryannhg"
            }
    }
