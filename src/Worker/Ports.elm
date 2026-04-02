port module Worker.Ports exposing (..)

import Json.Decode
import Json.Encode


port onMessage : (Json.Decode.Value -> msg) -> Sub msg


port sendMessage : Json.Encode.Value -> Cmd msg


port broadcast : Json.Encode.Value -> Cmd msg
