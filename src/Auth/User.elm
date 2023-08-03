module Auth.User exposing (GitHubInfo, SignInStatus(..), User)

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
    , github : Maybe GitHubInfo
    }


type alias GitHubInfo =
    { token : String
    , username : String
    }
