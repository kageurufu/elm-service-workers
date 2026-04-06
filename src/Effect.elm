module Effect exposing (Effect, batch, cmd, map, none, shared, toCmd)

import Browser.Navigation
import State.Shared
import Task


type Effect msg
    = None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
    | SharedMsg State.Shared.SharedMsg


map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd_ ->
            SendCmd (Cmd.map fn cmd_)

        SharedMsg sharedMsg_ ->
            SharedMsg sharedMsg_


toCmd :
    { key : Browser.Navigation.Key
    , fromSharedMsg : State.Shared.SharedMsg -> msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd_ ->
            cmd_

        SharedMsg sharedMsg_ ->
            Task.succeed sharedMsg_ |> Task.perform options.fromSharedMsg


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


cmd : Cmd msg -> Effect msg
cmd =
    SendCmd


shared : State.Shared.SharedMsg -> Effect msg
shared =
    SharedMsg
