module Worker exposing (main)

import Interop.Request
import Interop.Result
import Json.Decode
import Json.Encode
import Platform
import Time
import Worker.Event exposing (ClientId)


type alias Model =
    {}


type alias Flags =
    Json.Decode.Value


type Msg
    = OnRequest ClientId Interop.Request.Request
    | UpdateTime Time.Posix
    | NoOp


main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( {}, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Worker.Event.onMessage
            Interop.Request.requestDecoder
            handleMessage
        , Time.every 5000 UpdateTime
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateTime posix ->
            ( model
            , Worker.Event.broadcast
                (Interop.Result.encodeResult <|
                    Interop.Result.Time posix
                )
            )

        OnRequest clientId request ->
            ( model
            , Worker.Event.sendMessage
                clientId
                (Interop.Result.encodeResult <|
                    processRequest request
                )
            )


processRequest : Interop.Request.Request -> Interop.Result.InteropResult
processRequest request =
    case request of
        Interop.Request.Add a b ->
            Interop.Result.Add (a + b)

        Interop.Request.Echo s ->
            Interop.Result.Echo s


handleMessage : Result Json.Decode.Error ( ClientId, Interop.Request.Request ) -> Msg
handleMessage result =
    case result of
        Ok ( client, request ) ->
            OnRequest client request

        Err err ->
            let
                _ =
                    Debug.log "error" (Json.Decode.errorToString err)
            in
            NoOp
