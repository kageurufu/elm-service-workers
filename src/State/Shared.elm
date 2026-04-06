module State.Shared exposing (SharedModel, SharedMsg(..), decodeSharedModel, decodeSharedMsg, encodeSharedModel, encodeSharedMsg, init, sharedModelCodec, sharedMsgCodec, update)

import Dict
import Json.Decode
import Json.Encode
import Serialize as S
import State.Shared.TodoList as TodoList


type alias SharedModel =
    { groceryList : Dict.Dict String Int
    , todoList : TodoList.TodoListModel
    }


type SharedMsg
    = AddGroceryItem String
    | SetGroceryItemQuantity String Int
    | RemoveGroceryItem String
    | TodoListMsg TodoList.TodoListMsg
    | NoOp


init : SharedModel
init =
    { groceryList = Dict.fromList [ ( "Milk", 1 ) ,("Cookies", 12)]
    , todoList = TodoList.init
    }


update : SharedMsg -> SharedModel -> ( SharedModel, Cmd SharedMsg )
update msg model =
    case msg of
        AddGroceryItem name ->
            ( { model | groceryList = Dict.insert name 1 model.groceryList }, Cmd.none )

        SetGroceryItemQuantity name quantity ->
            ( { model | groceryList = Dict.insert name quantity model.groceryList }, Cmd.none )

        RemoveGroceryItem name ->
            ( { model | groceryList = Dict.remove name model.groceryList }, Cmd.none )

        TodoListMsg todoListMsg ->
            let
                ( todoListModel, todoListCmds ) =
                    TodoList.update todoListMsg model.todoList
            in
            ( { model | todoList = todoListModel }, Cmd.map TodoListMsg todoListCmds )

        NoOp ->
            ( model, Cmd.none )


sharedMsgCodec : S.Codec e SharedMsg
sharedMsgCodec =
    S.customType
        (\addGroceryItem setGroceryItemQuantity removeGroceryItem todoListMsgEncoder noOpEncoder value ->
            case value of
                AddGroceryItem s ->
                    addGroceryItem s

                SetGroceryItemQuantity s i ->
                    setGroceryItemQuantity s i

                RemoveGroceryItem s ->
                    removeGroceryItem s

                TodoListMsg m ->
                    todoListMsgEncoder m

                NoOp ->
                    noOpEncoder
        )
        |> S.variant1 AddGroceryItem S.string
        |> S.variant2 SetGroceryItemQuantity S.string S.int
        |> S.variant1 RemoveGroceryItem S.string
        |> S.variant1 TodoListMsg TodoList.todoListMsgCodec
        |> S.variant0 NoOp
        |> S.finishCustomType


encodeSharedMsg : SharedMsg -> Json.Encode.Value
encodeSharedMsg =
    S.encodeToJson sharedMsgCodec


decodeSharedMsg : Json.Encode.Value -> Result (S.Error e) SharedMsg
decodeSharedMsg =
    S.decodeFromJson sharedMsgCodec


sharedModelCodec : S.Codec e SharedModel
sharedModelCodec =
    S.record SharedModel
        |> S.field .groceryList (S.dict S.string S.int)
        |> S.field .todoList TodoList.todoListCodec
        |> S.finishRecord


encodeSharedModel : SharedModel -> Json.Encode.Value
encodeSharedModel sharedModel =
    S.encodeToJson sharedModelCodec sharedModel


decodeSharedModel : Json.Decode.Value -> Result (S.Error e) SharedModel
decodeSharedModel =
    S.decodeFromJson sharedModelCodec
