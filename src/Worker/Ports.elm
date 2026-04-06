port module Worker.Ports exposing (Client, onConnect, onMessage, send, sendToAll)

import Interop
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Serialize as S


type Client
    = Client Decode.Value


messageDecoder : Decode.Decoder ( Client, Decode.Value )
messageDecoder =
    Decode.succeed Tuple.pair
        |> required "client" (Decode.map Client Decode.value)
        |> required "data" Decode.value


onConnect : (Client -> msg) -> Sub msg
onConnect toMsg =
    newClient (\value -> Client value |> toMsg)


onMessage : (Decode.Error -> msg) -> (( Client, Decode.Value ) -> msg) -> Sub msg
onMessage toErrorMsg toMsg =
    receiveMessage
        (\value ->
            case Decode.decodeValue messageDecoder value of
                Ok success ->
                    success |> Debug.log "msg" |> toMsg

                Err err ->
                    err
                        |> Debug.log "err"
                        |> toErrorMsg
        )


send : Client -> Interop.Response -> Cmd msg
send (Client client) response =
    Encode.object
        [ ( "client", client )
        , ( "data", Interop.encodeResponse response )
        ]
        |> sendMessage


sendToAll : Interop.Response -> Cmd msg
sendToAll =
    Interop.encodeResponse
        >> broadcastMessage



-- Incoming Port


port receiveMessage : (Decode.Value -> msg) -> Sub msg


port newClient : (Decode.Value -> msg) -> Sub msg



-- Outgoing Ports


port broadcastMessage : Encode.Value -> Cmd msg


port sendMessage : Encode.Value -> Cmd msg
