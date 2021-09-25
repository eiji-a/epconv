--- Picshare

module Types exposing (..)

import Json.Decode exposing (Decoder, bool, decodeString, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Http

type alias Id =
  Int

type alias Tag =
  { id : Id
  , tag : String
  }

type alias Photo =
  { id : Id
  , url : String
  , status : String
  , xreso : Int
  , yreso : Int
  , filesize : Int
  , liked : Bool
  , tags : List Int
  }

type alias Feed =
  List Photo

type alias Model =
  { feed : Maybe Feed
  , error : Maybe Http.Error
  , streamQueue : Feed
  }

tagDecoder : Decoder Tag
tagDecoder =
  succeed Tag
    |> required "id" int
    |> required "tag" string

photoDecoder : Decoder Photo
photoDecoder =
  succeed Photo
    |> required "id" int
    |> required "url" string
    |> required "status" string
    |> required "xreso" int
    |> required "yreso" int
    |> required "filesize" int
    |> required "liked" bool
    |> required "tags" (list int)

initialModel : Model
initialModel =
  { feed = Nothing
  , error = Nothing
  , streamQueue = []
  }

tagList : List Tag
tagList =
  [ { id = 1, tag = "pussy" }
  , { id = 2, tag = "big boobs" }
  , { id = 3, tag = "armpit" }
  , { id = 4, tag = "ass" }
  , { id = 5, tag = "beauty" }
  , { id = 6, tag = "full nude" }
  , { id = 7, tag = "nipples" }
  , { id = 8, tag = "sex" }
  ]

type Msg
  = Next
  | ToggleLike Id
  | ToggleTrash Id
--  | UpdateComment Id String
--  | SaveComment Id
  | LoadFeed (Result Http.Error Feed)
--  | LoadStreamPhoto (Result Json.Decode.Error Photo)
--  | FlushStreamQueue

