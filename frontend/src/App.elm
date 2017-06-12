module App exposing (..)

import Html exposing (Html, text, div, img, span, li, ul, input, button, label)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import WebSocket exposing (..)
import Json.Decode exposing (Decoder, string, int, maybe)
import Json.Decode.Pipeline as JP exposing (decode, required)


type alias Model =
    { messages : Maybe (List Message)
    , filters : Maybe Filters
    }


type alias Filters =
    { filter : Maybe String
    , levels : Maybe (List String)
    }


type alias Message =
    { levelname : String
    , name : String
    , message : String
    , exec_info : Maybe String
    , lineno : Maybe Int
    , filename : Maybe String
    , asctime : Maybe String
    }


type alias LogRecord =
    { levelname : String
    , name : String
    , message : String
    , exec_info : Maybe String
    , lineno : Maybe Int
    , filename : Maybe String
    , asctime : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { messages = Nothing
      , filters = Nothing
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | WsMessage String
    | SetFilter String
    | ToggleLevel String
    | ClearFilter


decodeMessage : Result String LogRecord -> Message
decodeMessage payload =
    case payload of
        Err msg ->
            Message "Error decoding paylod:" "" msg Nothing Nothing Nothing Nothing

        Ok value ->
            Message value.levelname value.name value.message value.exec_info value.lineno value.filename value.asctime


addFilter : Model -> String -> Model
addFilter model filter =
    case model.filters of
        Nothing ->
            { model | filters = Just (Filters (Just filter) Nothing) }

        Just filters ->
            let
                levels =
                    filters.levels
            in
                { model | filters = Just (Filters (Just filter) levels) }


toggleFromList : Maybe (List a) -> a -> Maybe (List a)
toggleFromList list item =
    -- remove if in there
    case list of
        Nothing ->
            Just [ item ]

        Just list ->
            if List.member item list then
                let
                    filtered =
                        List.filter (\list_item -> list_item /= item) list
                in
                    if ((List.length filtered) > 0) then
                        Just filtered
                    else
                        Nothing
            else
                Just (item :: list)


toggleLevel : Model -> String -> Model
toggleLevel model level =
    case model.filters of
        Nothing ->
            { model | filters = Just (Filters Nothing (Just [ level ])) }

        Just filters ->
            let
                oldFilter =
                    filters.filter

                levels =
                    toggleFromList filters.levels level
            in
                { model | filters = Just (Filters oldFilter levels) }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        WsMessage msg ->
            let
                message =
                    decodeMessage
                        (Json.Decode.decodeString logDecoder msg)
            in
                case model.messages of
                    Nothing ->
                        ( { model | messages = Just [ message ] }, Cmd.none )

                    Just messages ->
                        ( { model | messages = Just (message :: messages) }, Cmd.none )

        SetFilter filter ->
            ( (addFilter model filter), Cmd.none )

        ToggleLevel level ->
            ( (toggleLevel model level), Cmd.none )

        ClearFilter ->
            ( { model | filters = Nothing }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ viewHeader model
        , viewMessages model
        ]



-- create list of Html Msg with the non nohting parts of the message


viewAsctime : Maybe String -> List (Html Msg) -> List (Html Msg)
viewAsctime asctime list =
    case asctime of
        Nothing ->
            list

        Just asctime ->
            List.append list [ span [ class "asctime" ] [ text asctime ] ]


viewFileName : Maybe String -> List (Html Msg) -> List (Html Msg)
viewFileName filename list =
    case filename of
        Nothing ->
            list

        Just filename ->
            List.append list [ span [ class "filename" ] [ text filename ] ]


viewExec : Maybe String -> List (Html Msg) -> List (Html Msg)
viewExec exec list =
    case exec of
        Nothing ->
            list

        Just exec ->
            List.append list [ span [ class "exec_info" ] [ text exec ] ]


viewLineNo : Maybe Int -> List (Html Msg) -> List (Html Msg)
viewLineNo lineNo list =
    case lineNo of
        Nothing ->
            list

        Just lineNo ->
            List.append list [ span [ class "lineNo" ] [ text ("line:" ++ (toString lineNo)) ] ]


hideMsg : Maybe Filters -> Message -> Bool
hideMsg filters message =
    case filters of
        Nothing ->
            False

        Just filter ->
            case filter.filter of
                Nothing ->
                    case filter.levels of
                        Nothing ->
                            False

                        Just levels ->
                            if List.member message.levelname levels then
                                False
                            else
                                True

                Just stringFilter ->
                    if String.contains stringFilter message.message then
                        case filter.levels of
                            Nothing ->
                                False

                            Just levels ->
                                if List.member message.levelname levels then
                                    False
                                else
                                    True
                    else
                        True


viewMessage : Maybe Filters -> Message -> Html Msg
viewMessage filter message =
    li [ hidden (hideMsg filter message) ]
        ([ span [ class message.levelname ] [ text message.levelname ]
         , span [ class "message" ] [ text message.message ]
         ]
            |> viewAsctime message.asctime
            |> viewLineNo message.lineno
            |> viewExec message.exec_info
            |> viewFileName message.filename
        )


viewMessages : Model -> Html Msg
viewMessages model =
    case model.messages of
        Nothing ->
            div [ class "content" ] [ text "waiting for logs" ]

        Just messages ->
            let
                listOfMessages =
                    List.map (viewMessage model.filters) messages
            in
                div [ class "content" ]
                    [ ul [ class "logs" ] listOfMessages
                    ]


isSelected : Model -> String -> Bool
isSelected model value =
    case model.filters of
        Nothing ->
            False

        Just filters ->
            case filters.levels of
                Nothing ->
                    False

                Just levels ->
                    if List.member value levels then
                        True
                    else
                        False



-- TODO this should really be an union type
-- with the messages


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "header" ]
        [ input [ type_ "text", placeholder "filter logs", onInput SetFilter ] []
        , selectedButton model "DEBUG"
        , selectedButton model "INFO"
        , selectedButton model "WARNING"
        , selectedButton model "ERROR"
        , button [ onClick ClearFilter ] [ text "clear" ]
        ]


selectedButton : Model -> String -> Html Msg
selectedButton model value =
    button
        [ onClick (ToggleLevel value)
        , classList
            [ ( "btn", True )
            , ( "btn_selected", (isSelected model value) )
            ]
        ]
        [ text value ]


checkbox : String -> Html Msg
checkbox name =
    label
        [ style [ ( "padding", "20px" ) ]
        ]
        [ input
            [ type_ "checkbox"
            , onClick (ToggleLevel name)
            ]
            []
        , text name
        ]


logDecoder : Decoder LogRecord
logDecoder =
    decode LogRecord
        |> JP.required "levelname" string
        |> JP.required "name" string
        |> JP.required "message" string
        |> JP.optional "exec_info" (maybe string) Nothing
        |> JP.optional "lineno" (maybe int) Nothing
        |> JP.optional "filename" (maybe string) Nothing
        |> JP.optional "asctime" (maybe string) Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:5678" WsMessage
