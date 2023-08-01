module Tests.Mock exposing (user)

import Auth.User


user : Auth.User.User
user =
    { id = "123"
    , name = "Ryan Haskell-Glatz"
    , email = "ryan@jangle.io"
    , image = Nothing
    , supabaseToken = "supabase_123"
    , githubToken = Just "github_123"
    , githubUsername = Just "ryannhg"
    }
