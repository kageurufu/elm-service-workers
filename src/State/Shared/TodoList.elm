module State.Shared.TodoList exposing (..)

import Dict
import Json.Decode
import Json.Encode
import Serialize as S


type alias TodoListModel =
    Dict.Dict String Bool


type TodoListMsg
    = AddItem String
    | RemoveItem String
    | UpdateItem String Bool


init : TodoListModel
init =
    Dict.fromList
        [ ( "Implement the missing features", False )
        , ( "Learn Elm", True )
        ]


update : TodoListMsg -> TodoListModel -> ( TodoListModel, Cmd TodoListMsg )
update msg model =
    case msg of
        AddItem todo ->
            ( Dict.insert todo False model, Cmd.none )

        RemoveItem todo ->
            ( Dict.remove todo model, Cmd.none )

        UpdateItem todo complete ->
            ( Dict.insert todo complete model, Cmd.none )


todoListCodec : S.Codec e TodoListModel
todoListCodec =
    S.dict S.string S.bool


todoListMsgCodec : S.Codec e TodoListMsg
todoListMsgCodec =
    S.customType
        (\addItemCodec removeItemCodec updateItemCodec value ->
            case value of
                AddItem s ->
                    addItemCodec s

                RemoveItem s ->
                    removeItemCodec s

                UpdateItem s b ->
                    updateItemCodec s b
        )
        |> S.variant1 AddItem S.string
        |> S.variant1 RemoveItem S.string
        |> S.variant2 UpdateItem S.string S.bool
        |> S.finishCustomType
