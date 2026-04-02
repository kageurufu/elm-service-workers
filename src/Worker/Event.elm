module Worker.Event exposing (ClientId, broadcast, onMessage, sendMessage)

import Json.Decode
import Json.Encode
import Worker.Ports


type ClientId
    = ClientId Json.Encode.Value


clientIdDecoder : Json.Decode.Decoder ClientId
clientIdDecoder =
    Json.Decode.map ClientId Json.Decode.value


encodeClientId : ClientId -> Json.Encode.Value
encodeClientId (ClientId value) =
    value


eventDecoder : Json.Decode.Decoder data -> Json.Decode.Decoder ( ClientId, data )
eventDecoder dataDecoder =
    Json.Decode.map2 Tuple.pair
        (Json.Decode.field "client" clientIdDecoder)
        (Json.Decode.field "data" dataDecoder)


encodeEvent : ClientId -> Json.Encode.Value -> Json.Encode.Value
encodeEvent clientId data =
    Json.Encode.object
        [ ( "client", encodeClientId clientId )
        , ( "data", data )
        ]


sendMessage : ClientId -> Json.Encode.Value -> Cmd msg
sendMessage clientId value =
    encodeEvent clientId value
        |> Worker.Ports.sendMessage


broadcast : Json.Encode.Value -> Cmd msg
broadcast =
    Worker.Ports.broadcast


onMessage : Json.Decode.Decoder data -> (Result Json.Decode.Error ( ClientId, data ) -> msg) -> Sub msg
onMessage dataDecoder createMsg =
    Worker.Ports.onMessage
        (Json.Decode.decodeValue (eventDecoder dataDecoder)
            >> createMsg
        )
