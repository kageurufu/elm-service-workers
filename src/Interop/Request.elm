module Interop.Request exposing (Request(..), add, echo, encodeRequest, requestDecoder)

import Interop.Helpers exposing (encodeVariantType)
import Json.Decode
import Json.Encode


type Request
    = Echo String
    | Add Int Int


encodeRequest : Request -> Json.Encode.Value
encodeRequest request =
    case request of
        Echo string ->
            encodeVariantType "echo" (Json.Encode.string string)

        Add a b ->
            encodeVariantType "add"
                (Json.Encode.object [ ( "a", Json.Encode.int a ), ( "b", Json.Encode.int b ) ])


requestDecoder : Json.Decode.Decoder Request
requestDecoder =
    Json.Decode.field "type" Json.Decode.string
        |> Json.Decode.andThen
            (\variant ->
                case variant of
                    "echo" ->
                        Json.Decode.map Echo (Json.Decode.field "value" Json.Decode.string)

                    "add" ->
                        Json.Decode.map2 Add
                            (Json.Decode.at [ "value", "a" ] Json.Decode.int)
                            (Json.Decode.at [ "value", "b" ] Json.Decode.int)

                    _ ->
                        Json.Decode.fail ("Unknown request variant " ++ variant)
            )


add : Int -> Int -> Json.Encode.Value
add a b =
    Add a b
        |> encodeRequest


echo : String -> Json.Encode.Value
echo s =
    Echo s |> encodeRequest
