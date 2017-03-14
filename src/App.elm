module App exposing (..)

import Html exposing (Html, text, div, img, span, li, ul, input, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import WebSocket exposing (..)


type alias Model =
    { messages : List Message
    , hilight : Maybe String
    }


type alias Message =
    { level : String
    , message : String
    , hilight : Bool
    , show : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { messages =
            [ Message "a" "b" False False
            ]
      , hilight = Nothing
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | WsMessage String
    | Search
    | SetSearch String
    | Clear


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        WsMessage msg ->
            let
                message =
                    Message "" msg False True
            in
                ( { model | messages = message :: model.messages }, Cmd.none )

        SetSearch query ->
            ( { model | hilight = Just query }, Cmd.none )

        Search ->
            search model

        Clear ->
            clear model


clear : Model -> ( Model, Cmd Msg )
clear model =
    let
        messages =
            List.map (\message -> { message | hilight = False, show = True }) model.messages
    in
        ( { model | messages = messages }, Cmd.none )


hilight : Maybe String -> Message -> Message
hilight query message =
    case query of
        Nothing ->
            message

        Just query ->
            if String.contains query message.message then
                { message | hilight = True }
            else
                message


search : Model -> ( Model, Cmd Msg )
search model =
    let
        messages =
            List.map (hilight model.hilight) model.messages
    in
        ( { model | messages = messages }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ viewHeader
        , viewMessages model.messages
        ]


hilightClass : Bool -> String
hilightClass b =
    if b == True then
        "hilight_line"
    else
        "line"


viewMessage : Message -> Html Msg
viewMessage message =
    li [ class (hilightClass message.hilight), hidden (not message.show) ]
        [ div [ class message.level ] [ text message.level ]
        , div [] [ text message.message ]
        ]


viewMessages : List Message -> Html Msg
viewMessages messages =
    let
        listOfMessages =
            List.map viewMessage messages
    in
        div [ class "content" ]
            [ ul [ class "logs" ] listOfMessages
            ]


viewHeader : Html Msg
viewHeader =
    div [ class "header" ]
        [ input [ type_ "text", placeholder "Search logs", onInput SetSearch ] []
        , button [ onClick Search ] [ text "Search" ]
        , button [ onClick Clear ] [ text "clear" ]
        , button [ onClick Clear ] [ text "debug" ]
        , button [ onClick Clear ] [ text "info" ]
        , button [ onClick Clear ] [ text "warning" ]
        , button [ onClick Clear ] [ text "error" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:5678" WsMessage
