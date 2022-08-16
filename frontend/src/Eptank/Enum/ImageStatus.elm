-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Eptank.Enum.ImageStatus exposing (..)

import Json.Decode as Decode exposing (Decoder)


type ImageStatus
    = Pending
    | Filed
    | Discarded
    | Deleted


list : List ImageStatus
list =
    [ Pending, Filed, Discarded, Deleted ]


decoder : Decoder ImageStatus
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "pending" ->
                        Decode.succeed Pending

                    "filed" ->
                        Decode.succeed Filed

                    "discarded" ->
                        Decode.succeed Discarded

                    "deleted" ->
                        Decode.succeed Deleted

                    _ ->
                        Decode.fail ("Invalid ImageStatus type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : ImageStatus -> String
toString enum____ =
    case enum____ of
        Pending ->
            "pending"

        Filed ->
            "filed"

        Discarded ->
            "discarded"

        Deleted ->
            "deleted"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe ImageStatus
fromString enumString____ =
    case enumString____ of
        "pending" ->
            Just Pending

        "filed" ->
            Just Filed

        "discarded" ->
            Just Discarded

        "deleted" ->
            Just Deleted

        _ ->
            Nothing
