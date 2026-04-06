module Worker exposing (main)

import Interop
import Json.Decode as Decode
import Rpc
import Serialize as S
import State.Shared exposing (SharedModel)
import Worker.Ports as Ports


type alias WorkerModel =
    { sharedModel : SharedModel
    }


type WorkerMsg
    = SharedMsg State.Shared.SharedMsg
    | Rpc Ports.Client Rpc.RpcCommand
    | NewClient Ports.Client
    | NoOp


main : Program () WorkerModel WorkerMsg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( WorkerModel, Cmd WorkerMsg )
init _ =
    ( { sharedModel = State.Shared.init }
    , Cmd.none
    )


update : WorkerMsg -> WorkerModel -> ( WorkerModel, Cmd WorkerMsg )
update msg model =
    case Debug.log "msg" msg of
        SharedMsg sharedMsg ->
            let
                ( newSharedModel, sharedCmds ) =
                    State.Shared.update sharedMsg model.sharedModel
            in
            ( { model | sharedModel = newSharedModel }
            , Cmd.batch
                [ Cmd.map SharedMsg sharedCmds
                , Ports.sendToAll (Interop.SharedModel newSharedModel)
                ]
            )

        Rpc client rpcCommand ->
            let
                result =
                    Rpc.process rpcCommand
            in
            ( model
            , Ports.send client (Interop.RpcResult result)
            )

        NewClient client ->
            ( model
            , Ports.send client (Interop.SharedModel model.sharedModel)
            )

        NoOp ->
            ( model, Cmd.none )


handleMessage : ( Ports.Client, Decode.Value ) -> WorkerMsg
handleMessage ( client, value ) =
    case S.decodeFromJson Interop.requestCodec value of
        Ok (Interop.SharedMsg sharedMsg) ->
            SharedMsg sharedMsg

        Ok (Interop.RpcCommand rpcCommand) ->
            Rpc client rpcCommand

        Err _ ->
            Debug.todo "branch 'Err _' not implemented"


subscriptions : WorkerModel -> Sub WorkerMsg
subscriptions _ =
    Sub.batch
        [ Ports.onMessage (always NoOp) handleMessage
        , Ports.onConnect NewClient
        ]
