--- View

module View exposing (view)

{-
import Browser
import Json.Decode exposing (Decoder, bool, decodeString, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
-}
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http

import Types exposing (..)

viewLoveButton : Photo -> Html Msg
viewLoveButton photo =
  let
    heartClass =
      if photo.liked then
        "fa fa-heart fa-red"
      else
        "far fa-heart"
    trashClass =
      if photo.status == "discarded" then
        "fa fa-trash-alt fa-blue"
      else
        "far fa-trash-alt"
  in
  div []
    [ span [ class "icon" ]
      [ i
        [ class heartClass
        , onClick (if photo.liked == False then Like photo.id else Dislike photo.id)
        ]
        []
      ]
    , span [ class "icon" ]
      [ i
        [ class trashClass
        , onClick (if photo.status == "discarded" then Undiscard photo.id else Trash photo.id)
        ]
        []
      ]
    , span [ class "icon" ]
      [ a [ class "modal-button"
          , target "modal-bis"
          , href (baseUrl ++ "image/" ++ (String.fromInt photo.id))
          ]
        [ i [ class "fa fa-expand is-dark" ]
          []
        ]
      ]
    ]

viewSize : Photo -> Html Msg
viewSize photo =
  let
    kb = (photo.filesize // 1000)
  in
  div []
    [ strong [] [ text "Size:" ]
    , text (  " "
           ++ (String.fromInt photo.xreso) ++ "x" ++ (String.fromInt photo.yreso)
           ++ " / " ++ (String.fromInt kb) ++ " KB"
           )
    ]

viewInfoBar : Photo -> Html Msg
viewInfoBar photo =
  nav [ class "level" ]
    [ div [ class "level-left" ]
        [ viewSize photo ]
    , div [ class "level-right" ]
        [ viewLoveButton photo ]
    ]

viewTag : Bool -> Tag -> Html Msg
viewTag tf tag =
  let
    flag =
      if tf == True then
        ""
      else
        " is-light"
  in
  button [ class ("button is-link" ++ flag) ]
    [ text tag.tag ]

viewTagBar : Photo -> Html Msg
viewTagBar photo =
  div [ class "buttons are-small" ]
    (List.map (viewTag False) tagList)

viewDetailedPhoto : Photo -> Html Msg
viewDetailedPhoto photo =
  let
    opacity =
      if photo.status == "discarded" then
        "image-discarded"
      else
        ""
    bgcolor =
      if photo.status == "pending" then
        "-pending"
      else
        ""
    url = baseUrl ++ "image/" ++ (String.fromInt photo.id)
  in
  div [ class "column" ]
    [ div [ class "box"
          , class ("image-body" ++ bgcolor)
          ]
      [ viewInfoBar photo
      --, viewTagBar photo
      , span
        [ 
        ]
        [ div [] -- class "border-selected" ]
          [ a [ class "modal-button"
              , target "modal-bis"
              , href url
              ]
            [ img
                [ src url
                , class opacity
                , title photo.filename
                ]
                []
            ]
          ]
        ]
      ]
    , div [ class "modal"
          , id "modal-bis"
          ]
      [ div [ class "modal-background" ] []
      , div [ class "modal-content" ]
        [ p [ class "image is-4by3" ]
          [ img [ src url
                , alt ""
                ]
            []
          ]
        ]
      , button
        [ class "modal-close is-large"
        ]
        [ label [] [ text "close" ]
        ]
      ]
    ]

viewFeed : Maybe Feed -> Html Msg
viewFeed maybeFeed =
  case maybeFeed of
    Just feed ->
      div [ class "columns" ] (List.map viewDetailedPhoto feed)
    Nothing ->
      div [ class "loading-feed" ]
        [ text "Loading Feed..." ]

errorMessage : Http.Error -> String
errorMessage error =
  case error of
    Http.BadBody _ ->
      """Sorry, we couldn't proccess your feed at this time.
      We're working on it!"""
    _ ->
      """Sorry, we couldn't load your feed at this time.
      Please try again later."""
{-
viewStreamNotification : Feed -> Html Msg
viewStreamNotification queue =
  case queue of
    [] ->
      text ""
    _ ->
      let
        content =
          "View new photos: " ++ String.fromInt (List.length queue)
      in
      div
        [ class "stream-notification"
        , onClick FlushStreamQueue
        ]
        [ text content ]
-}

viewContent : Model -> Html Msg
viewContent model =
  case model.error of
    Just error ->
      div [ class "feed-error" ]
        [ text (errorMessage error) ]
    Nothing ->
      div []
        [ --viewStreamNotification model.streamQueue
        viewFeed model.feed          
        ]

view : Model -> Html Msg
view model =
  div []
    [ nav [ class "level" ]
      [ div [ class "level-left" ]
        [ section [ class "hero" ]
          [ div [ class "hero-body" ]
            [ p [ class "title" ]
              [ text "EP Tank" ]
            , p [ class "subtitle" ]
              [ text "Beautiful Ladies"]
            ]
          ]
        ]

      , div [ class "level-right" ]
        [ p [ class "level-item" ]
          [ div []
            [ div []
              [ button [ class "button is-link"
                       , onClick Next
                       ]
                [ i [ class "fas fa-play-circle fa-fw" ]
                  []
                , strong [] [ text "Next" ]
                ]
              ]
            ]
          ]
        , div [ class "level-item" ]
          []
        ]
      ]
    , div []
        [ viewContent model ]
    ]

