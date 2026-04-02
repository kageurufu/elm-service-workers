module Interop.Result exposing (InteropResult(..), encodeResult, resultDecoder)

import Interop.Helpers exposing (encodeVariantType)
import Json.Decode
import Json.Encode
import Time


type InteropResult
    = Echo String
    | Add Int
    | Time Time.Posix


encodeResult : InteropResult -> Json.Encode.Value
encodeResult result =
    case result of
        Echo string ->
            encodeVariantType "echo" (Json.Encode.string string)

        Add int ->
            encodeVariantType "add" (Json.Encode.int int)

        Time time ->
            encodeVariantType "time" (Json.Encode.int (Time.posixToMillis time))


resultDecoder : Json.Decode.Decoder InteropResult
resultDecoder =
    Json.Decode.field "type" Json.Decode.string
        |> Json.Decode.andThen
            (\variant ->
                case variant of
                    "echo" ->
                        Json.Decode.map Echo
                            (Json.Decode.field "value" Json.Decode.string)

                    "add" ->
                        Json.Decode.map Add
                            (Json.Decode.field "value" Json.Decode.int)

                    "time" ->
                        Json.Decode.map Time
                            (Json.Decode.field "value" Json.Decode.int
                                |> Json.Decode.map Time.millisToPosix
                            )

                    _ ->
                        Json.Decode.fail ("Unknown result variant " ++ variant)
            )
