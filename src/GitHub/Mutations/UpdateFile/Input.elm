module GitHub.Mutations.UpdateFile.Input exposing
    ( Input, new
    , branchId, expectedHeadOid, message, path, contents
    , toInternalValue
    )

{-|

@docs Input, new

@docs branchId, expectedHeadOid, message, path, contents
@docs null

@docs toInternalValue

-}

import Dict exposing (Dict)
import GitHub.Scalars.Base64String
import GitHub.Scalars.GitObjectID
import GraphQL.Encode
import GraphQL.Scalar.Id


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new :
    Input
        { missing
            | branchId : GraphQL.Scalar.Id.Id
            , expectedHeadOid : GitHub.Scalars.GitObjectID.GitObjectID
            , message : String
            , path : String
            , contents : GitHub.Scalars.Base64String.Base64String
        }
new =
    Input Dict.empty


branchId :
    GraphQL.Scalar.Id.Id
    -> Input { missing | branchId : GraphQL.Scalar.Id.Id }
    -> Input missing
branchId value_ (Input dict_) =
    Input (Dict.insert "branchId" (GraphQL.Encode.id value_) dict_)


expectedHeadOid :
    GitHub.Scalars.GitObjectID.GitObjectID
    -> Input { missing | expectedHeadOid : GitHub.Scalars.GitObjectID.GitObjectID }
    -> Input missing
expectedHeadOid value_ (Input dict_) =
    Input (Dict.insert "expectedHeadOid" (GitHub.Scalars.GitObjectID.encode value_) dict_)


message :
    String
    -> Input { missing | message : String }
    -> Input missing
message value_ (Input dict_) =
    Input (Dict.insert "message" (GraphQL.Encode.string value_) dict_)


path :
    String
    -> Input { missing | path : String }
    -> Input missing
path value_ (Input dict_) =
    Input (Dict.insert "path" (GraphQL.Encode.string value_) dict_)


contents :
    GitHub.Scalars.Base64String.Base64String
    -> Input { missing | contents : GitHub.Scalars.Base64String.Base64String }
    -> Input missing
contents value_ (Input dict_) =
    Input (Dict.insert "contents" (GitHub.Scalars.Base64String.encode value_) dict_)


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
