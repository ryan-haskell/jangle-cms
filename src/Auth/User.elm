module Auth.User exposing (SignInStatus(..), User)

import Supabase.OAuthResponse


type SignInStatus
    = NotSignedIn
    | FetchingUserDetails Supabase.OAuthResponse.OAuthResponse
    | SignedIn User


type alias User =
    { id : String
    , name : String
    , email : String
    , image : Maybe String
    , supabaseToken : String
    , githubToken : Maybe String
    , githubUsername : Maybe String
    }
