module Auth.User exposing
    ( GitHubInfo
    , SignInStatus(..)
    , User
    , encode
    )

import Json.Encode
import Json.Encode.Extra
import Supabase.OAuthResponse
import Supabase.Scalars.UUID exposing (UUID)


type SignInStatus
    = NotSignedIn
    | FetchingUserDetails Supabase.OAuthResponse.OAuthResponse
    | SignedIn User


type alias User =
    { id : UUID
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


encode : User -> Json.Encode.Value
encode user =
    Json.Encode.object
        [ ( "id", Json.Encode.string (Supabase.Scalars.UUID.toString user.id) )
        , ( "name", Json.Encode.string user.name )
        , ( "username"
          , user.github
                |> Maybe.map .username
                |> Json.Encode.Extra.maybe Json.Encode.string
          )
        , ( "email", Json.Encode.string user.email )
        , ( "avatar", Json.Encode.Extra.maybe Json.Encode.string user.image )
        ]
