port module Frontend.Ports exposing (onMessage, send)

import Interop
import Json.Decode as Decode
import Json.Encode as Encode
import Serialize as S


onMessage : (S.Error err -> msg) -> (Interop.Response -> msg) -> Sub msg
onMessage toError toMsg =
    receiveMessage
        (\value ->
            case S.decodeFromJson Interop.responseCodec value of
                Ok response ->
                    toMsg response

                Err err ->
                    toError err
        )


send : Interop.Request -> Cmd msg
send request =
    S.encodeToJson Interop.requestCodec request |> sendMessage



-- Ports


port receiveMessage : (Decode.Value -> msg) -> Sub msg


port sendMessage : Encode.Value -> Cmd msg
