module Auth.User exposing (User)


type alias User =
    { name : String
    , email : String
    , image : Maybe String
    }
