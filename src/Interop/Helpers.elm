module Interop.Helpers exposing (..)

import Json.Encode


encodeVariantType : String -> Json.Encode.Value -> Json.Encode.Value
encodeVariantType type_ value =
    Json.Encode.object [ ( "type", Json.Encode.string type_ ), ( "value", value ) ]
