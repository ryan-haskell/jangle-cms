module Jangle.Settings exposing
    ( Settings, new
    , decoder, encode
    , ContentType
    , SingleContentType, ManyContentType
    , FileKind
    , Field
    , TextField, MultilineField
    , DateField, DateDefault
    , SelectField, MultiselectField
    , Choices, FixedChoices, ValueLabelPair
    )

{-|

@docs Settings, new
@docs decoder, encode

@docs ContentType
@docs SingleContentType, ManyContentType
@docs FileKind

@docs Field
@docs TextField, MultilineField
@docs DateField, DateDefault
@docs SelectField, MultiselectField

@docs Choices, FixedChoices, ValueLabelPair

-}

import Codec exposing (Codec)
import Dict exposing (Dict)
import Json.Decode
import Json.Encode


type alias Settings =
    { title : String
    , contentTypes : List ContentType
    }


new : { title : String } -> Settings
new props =
    { title = props.title
    , contentTypes = []
    }


codec : Codec Settings
codec =
    Codec.object Settings
        |> Codec.field "title" .title Codec.string
        |> Codec.field "contentTypes" .contentTypes (Codec.list contentTypeCodec)
        |> Codec.buildObject


decoder : Json.Decode.Decoder Settings
decoder =
    Codec.decoder codec


encode : Settings -> Json.Encode.Value
encode =
    Codec.encoder codec


type ContentType
    = Single SingleContentType
    | Many ManyContentType


contentTypeCodec : Codec ContentType
contentTypeCodec =
    Codec.custom
        (\single many value ->
            case value of
                Single props ->
                    single props

                Many props ->
                    many props
        )
        |> Codec.variant1 "Single" Single singleContentTypeCodec
        |> Codec.variant1 "Many" Many manyContentTypeCodec
        |> Codec.buildCustom


type alias SingleContentType =
    { path : String
    , kindOfFile : FileKind
    , fields : List Field
    , hasRichTextEditor : Bool
    }


singleContentTypeCodec : Codec SingleContentType
singleContentTypeCodec =
    Codec.object SingleContentType
        |> Codec.field "path" .path Codec.string
        |> Codec.field "kindOfFile" .kindOfFile fileKindCodec
        |> Codec.field "fields" .fields (Codec.list fieldCodec)
        |> Codec.field "hasRichTextEditor" .hasRichTextEditor Codec.bool
        |> Codec.buildObject


type alias ManyContentType =
    { path : String
    , kindOfFile : FileKind
    , fields : List Field
    , hasRichTextEditor : Bool
    }


manyContentTypeCodec : Codec ManyContentType
manyContentTypeCodec =
    Codec.object ManyContentType
        |> Codec.field "path" .path Codec.string
        |> Codec.field "kindOfFile" .kindOfFile fileKindCodec
        |> Codec.field "fields" .fields (Codec.list fieldCodec)
        |> Codec.field "hasRichTextEditor" .hasRichTextEditor Codec.bool
        |> Codec.buildObject


type FileKind
    = Json
    | Markdown


fileKindCodec : Codec FileKind
fileKindCodec =
    Codec.custom
        (\json markdown value ->
            case value of
                Json ->
                    json

                Markdown ->
                    markdown
        )
        |> Codec.variant0 "Json" Json
        |> Codec.variant0 "Markdown" Markdown
        |> Codec.buildCustom


type Field
    = Field_Text TextField
    | Field_Multiline MultilineField
    | Field_Date DateField
    | Field_Select SelectField
    | Field_Multiselect MultiselectField


fieldCodec : Codec Field
fieldCodec =
    Codec.custom
        (\fieldText fieldMultiline fieldDate fieldSelect fieldMultiselect value ->
            case value of
                Field_Text props ->
                    fieldText props

                Field_Multiline props ->
                    fieldMultiline props

                Field_Date props ->
                    fieldDate props

                Field_Select props ->
                    fieldSelect props

                Field_Multiselect props ->
                    fieldMultiselect props
        )
        |> Codec.variant1 "Text" Field_Text textFieldCodec
        |> Codec.variant1 "Multiline" Field_Multiline multilineFieldCodec
        |> Codec.variant1 "Date" Field_Date dateFieldCodec
        |> Codec.variant1 "Select" Field_Select selectFieldCodec
        |> Codec.variant1 "Multiselect" Field_Multiselect multiselectFieldCodec
        |> Codec.buildCustom


type alias TextField =
    { label : String
    , description : Maybe String
    , isRequired : Bool
    }


textFieldCodec : Codec TextField
textFieldCodec =
    Codec.object TextField
        |> Codec.field "label" .label Codec.string
        |> Codec.field "description" .description (Codec.maybe Codec.string)
        |> Codec.field "isRequired" .isRequired Codec.bool
        |> Codec.buildObject


type alias MultilineField =
    { label : String
    , description : Maybe String
    , isRequired : Bool
    , isRichText : Bool
    }


multilineFieldCodec : Codec MultilineField
multilineFieldCodec =
    Codec.object MultilineField
        |> Codec.field "label" .label Codec.string
        |> Codec.field "description" .description (Codec.maybe Codec.string)
        |> Codec.field "isRequired" .isRequired Codec.bool
        |> Codec.field "isRichText" .isRichText Codec.bool
        |> Codec.buildObject


type alias DateField =
    { label : String
    , description : Maybe String
    , isRequired : Bool
    , default : Maybe DateDefault
    }


dateFieldCodec : Codec DateField
dateFieldCodec =
    Codec.object DateField
        |> Codec.field "label" .label Codec.string
        |> Codec.field "description" .description (Codec.maybe Codec.string)
        |> Codec.field "isRequired" .isRequired Codec.bool
        |> Codec.field "default" .default (Codec.maybe dateDefaultCodec)
        |> Codec.buildObject


type DateDefault
    = Now


dateDefaultCodec : Codec DateDefault
dateDefaultCodec =
    Codec.custom
        (\now value ->
            case value of
                Now ->
                    now
        )
        |> Codec.variant0 "Now" Now
        |> Codec.buildCustom


type alias SelectField =
    { label : String
    , description : Maybe String
    , isRequired : Bool
    , choices : Choices
    }


selectFieldCodec : Codec SelectField
selectFieldCodec =
    Codec.object SelectField
        |> Codec.field "label" .label Codec.string
        |> Codec.field "description" .description (Codec.maybe Codec.string)
        |> Codec.field "isRequired" .isRequired Codec.bool
        |> Codec.field "choices" .choices choicesCodec
        |> Codec.buildObject


type alias MultiselectField =
    { label : String
    , description : Maybe String
    , isRequired : Bool
    , choices : Choices
    }


multiselectFieldCodec : Codec MultiselectField
multiselectFieldCodec =
    Codec.object MultiselectField
        |> Codec.field "label" .label Codec.string
        |> Codec.field "description" .description (Codec.maybe Codec.string)
        |> Codec.field "isRequired" .isRequired Codec.bool
        |> Codec.field "choices" .choices choicesCodec
        |> Codec.buildObject


type Choices
    = Fixed FixedChoices
    | Dynamic


choicesCodec : Codec Choices
choicesCodec =
    Codec.custom
        (\fixed dynamic value ->
            case value of
                Fixed props ->
                    fixed props

                Dynamic ->
                    dynamic
        )
        |> Codec.variant1 "Fixed" Fixed fixedChoicesCodec
        |> Codec.variant0 "Dynamic" Dynamic
        |> Codec.buildCustom


type alias FixedChoices =
    { choices : List ValueLabelPair
    }


fixedChoicesCodec : Codec FixedChoices
fixedChoicesCodec =
    Codec.object FixedChoices
        |> Codec.field "choices" .choices (Codec.list valueLabelPairCodec)
        |> Codec.buildObject


type alias ValueLabelPair =
    { value : String
    , label : String
    }


valueLabelPairCodec : Codec ValueLabelPair
valueLabelPairCodec =
    Codec.object ValueLabelPair
        |> Codec.field "value" .value Codec.string
        |> Codec.field "label" .label Codec.string
        |> Codec.buildObject
