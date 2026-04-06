module Rpc exposing (..)

import Serialize as S
import Json.Decode as Decode
import Json.Encode as Encode

type RpcCommand
    = Add Int Int
    | Echo String
    | Ping


type RpcResult
    = Sum Int
    | Echoed String
    | Pong


process : RpcCommand -> RpcResult
process cmd =
    case cmd of
        Add a b ->
            Sum (a + b)

        Echo val ->
            Echoed val

        Ping ->
            Pong


rpcCommandCodec : S.Codec e RpcCommand
rpcCommandCodec =
    S.customType
        (\add echo ping value ->
            case value of
                Add a b ->
                    add a b

                Echo s ->
                    echo s

                Ping ->
                    ping
        )
        |> S.variant2 Add S.int S.int
        |> S.variant1 Echo S.string
        |> S.variant0 Ping
        |> S.finishCustomType


rpcResultCodec : S.Codec e RpcResult
rpcResultCodec =
    S.customType
        (\sum echoed pong value ->
            case value of
                Sum v ->
                    sum v

                Echoed v ->
                    echoed v

                Pong ->
                    pong
        )
        |> S.variant1 Sum S.int
        |> S.variant1 Echoed S.string
        |> S.variant0 Pong
        |> S.finishCustomType

encodeCommand : RpcCommand -> Encode.Value
encodeCommand = S.encodeToJson rpcCommandCodec
decodeCommand : Decode.Value -> Result (S.Error e) RpcCommand
decodeCommand = S.decodeFromJson rpcCommandCodec
encodeResult : RpcResult -> Encode.Value
encodeResult = S.encodeToJson rpcResultCodec
decodeResult : Decode.Value -> Result (S.Error e) RpcResult
decodeResult = S.decodeFromJson rpcResultCodec
