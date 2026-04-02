port module Frontend exposing (main)

import Browser
import Html exposing (Html, a, button, div, h2, h4, header, input, li, ol, text)
import Html.Attributes exposing (href, type_, value)
import Html.Events exposing (onClick, onInput)
import Interop.Request
import Interop.Result
import Json.Decode
import Json.Encode
import Time
import Util exposing (formatTime)


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { worker : String
    }


type alias Model =
    { worker : Maybe String
    , echoValue : String
    , aValue : Int
    , bValue : Int
    , messages : List String
    , time : Maybe Time.Posix
    }


type Msg
    = EchoValueChanged String
    | SendEcho
    | AddAChanged String
    | AddBChanged String
    | SendAdd
    | NoOp
    | OnResult (Result Json.Decode.Error Interop.Result.InteropResult)


flagsDecoder : Json.Decode.Decoder Flags
flagsDecoder =
    Json.Decode.map Flags
        (Json.Decode.field "worker" Json.Decode.string)


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flagsValue =
    let
        worker =
            Json.Decode.decodeValue flagsDecoder flagsValue
                |> Result.toMaybe
                |> Maybe.map .worker
    in
    ( { worker = worker
      , echoValue = "ping!"
      , aValue = 1
      , bValue = 2
      , messages = []
      , time = Nothing
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    onMessage handleResult


handleResult : Json.Encode.Value -> Msg
handleResult value =
    OnResult <|
        Json.Decode.decodeValue Interop.Result.resultDecoder value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EchoValueChanged v ->
            ( { model | echoValue = v }, Cmd.none )

        AddAChanged val ->
            ( { model | aValue = Maybe.withDefault model.aValue (String.toInt val) }
            , Cmd.none
            )

        AddBChanged val ->
            ( { model | bValue = Maybe.withDefault model.bValue (String.toInt val) }
            , Cmd.none
            )

        SendEcho ->
            ( model
            , sendMessage (Interop.Request.echo model.echoValue)
            )

        SendAdd ->
            ( model
            , sendMessage (Interop.Request.add model.aValue model.bValue)
            )

        OnResult (Ok result) ->
            case result of
                Interop.Result.Add sum ->
                    ( { model | messages = ("sum = " ++ String.fromInt sum) :: model.messages }, Cmd.none )

                Interop.Result.Echo s ->
                    ( { model | messages = ("echoed \"" ++ s ++ "\"") :: model.messages }, Cmd.none )

                Interop.Result.Time time ->
                    ( { model | time = Just time }, Cmd.none )

        OnResult (Err err) ->
            ( { model | messages = ("ERROR! " ++ Json.Decode.errorToString err) :: model.messages }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "service worker tests"
    , body =
        [ h2
            []
            [ text "Frontend goes here" ]
        , header []
            [ text "Run using a "
            , a [ href "?service_worker" ] [ text "Service Worker" ]
            , text ", "
            , a [ href "?shared_worker" ] [ text "Shared Worker" ]
            , text ", or "
            , a [ href "?web_worker" ] [ text "Web Worker" ]
            ]
        , case model.worker of
            Just worker ->
                div []
                    [ text ("Worker running as " ++ worker ++ "!")
                    , div []
                        [ case model.time of
                            Just posix ->
                                text ("last broadcast: " ++ formatTime posix)

                            Nothing ->
                                text "no time broadcasts from a worker"
                        ]
                    , div []
                        [ input [ value model.echoValue, onInput EchoValueChanged ] []
                        , button [ onClick SendEcho ] [ text "echo" ]
                        ]
                    , div []
                        [ input [ type_ "number", value (String.fromInt model.aValue), onInput AddAChanged ] []
                        , text "+"
                        , input [ type_ "number", value (String.fromInt model.bValue), onInput AddBChanged ] []
                        , button [ onClick SendAdd ] [ text "add" ]
                        ]
                    ]

            _ ->
                div [] [ text "service worker missing, cannot do anything" ]
        , div []
            [ h4 [] [ text "Received messages" ]
            , ol [] (List.map (\message -> li [] [ text message ]) model.messages)
            ]
        ]
    }


port onMessage : (Json.Encode.Value -> msg) -> Sub msg


port sendMessage : Json.Encode.Value -> Cmd msg
