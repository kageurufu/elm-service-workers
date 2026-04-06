module Interop exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Rpc
import Serialize as S
import State.Shared


type Request
    = SharedMsg State.Shared.SharedMsg
    | RpcCommand Rpc.RpcCommand


type Response
    = RpcResult Rpc.RpcResult
    | SharedModel State.Shared.SharedModel


requestCodec : S.Codec e Request
requestCodec =
    S.customType
        (\sharedMsg rpcCommand value ->
            case value of
                SharedMsg s ->
                    sharedMsg s

                RpcCommand r ->
                    rpcCommand r
        )
        |> S.variant1 SharedMsg State.Shared.sharedMsgCodec
        |> S.variant1 RpcCommand Rpc.rpcCommandCodec
        |> S.finishCustomType


responseCodec : S.Codec e Response
responseCodec =
    S.customType
        (\rpcResult sharedModel value ->
            case value of
                RpcResult r ->
                    rpcResult r

                SharedModel s ->
                    sharedModel s
        )
        |> S.variant1 RpcResult Rpc.rpcResultCodec
        |> S.variant1 SharedModel State.Shared.sharedModelCodec
        |> S.finishCustomType


encodeRequest : Request -> Encode.Value
encodeRequest =
    S.encodeToJson requestCodec


decodeRequest : Decode.Value -> Result (S.Error e) Request
decodeRequest =
    S.decodeFromJson requestCodec


encodeResponse : Response -> Encode.Value
encodeResponse =
    S.encodeToJson responseCodec


decodeResponse : Decode.Value -> Result (S.Error e) Response
decodeResponse =
    S.decodeFromJson responseCodec
