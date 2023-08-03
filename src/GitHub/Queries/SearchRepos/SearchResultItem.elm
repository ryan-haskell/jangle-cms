module GitHub.Queries.SearchRepos.SearchResultItem exposing
    ( SearchResultItem(..)
    , Repository
    )

{-|

@docs SearchResultItem
@docs Repository

-}


type SearchResultItem
    = OnRepository Repository


type alias Repository =
    { databaseId : Maybe Int
    , nameWithOwner : String
    }
