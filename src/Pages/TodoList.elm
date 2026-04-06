module Pages.TodoList exposing (..)

import Dict
import Effect exposing (Effect)
import Element
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import State.Shared
import State.Shared.TodoList


type alias Model =
    { newItem : String
    }


type Msg
    = UpdateNewItem String
    | AddNewItem
    | SetItemCompleted String Bool
    | NoOp


init : State.Shared.SharedModel -> Model
init _ =
    { newItem = "" }


title : Model -> String
title _ =
    "Todo List"


update : Msg -> Model -> State.Shared.SharedModel -> ( Model, Effect msg )
update msg model _ =
    case msg of
        UpdateNewItem newItem ->
            ( { model | newItem = newItem }, Effect.none )

        AddNewItem ->
            ( { model | newItem = "" }
            , Effect.shared (State.Shared.TodoListMsg (State.Shared.TodoList.AddItem model.newItem))
            )

        SetItemCompleted item complete ->
            ( model
            , Effect.shared (State.Shared.TodoListMsg (State.Shared.TodoList.UpdateItem item complete))
            )

        NoOp ->
            ( model, Effect.none )


view : Model -> State.Shared.SharedModel -> Element.Element Msg
view model sharedModel =
    Element.column
        [ Element.centerX
        , Element.spacing 15
        ]
        [ viewTodoList sharedModel, viewNewItem model ]


viewTodoList : State.Shared.SharedModel -> Element.Element Msg
viewTodoList sharedModel =
    Element.column [ Element.width Element.fill, Element.spacing 10 ]
        (sharedModel.todoList
            |> Dict.toList
            |> List.sortBy
                (\( _, complete ) ->
                    if complete then
                        1

                    else
                        -1
                )
            |> List.map
                (\( todo, complete ) ->
                    Element.row [ Element.width Element.fill, Element.spaceEvenly ]
                        [ Element.el [ Element.Font.color <| todoItemColor complete ] <| Element.text todo
                        , Element.Input.checkbox [ Element.width Element.shrink ]
                            { checked = complete
                            , onChange = SetItemCompleted todo
                            , icon = Element.Input.defaultCheckbox
                            , label = Element.Input.labelHidden "Complete"
                            }
                        ]
                )
        )


todoItemColor : Bool -> Element.Color
todoItemColor complete =
    if complete then
        Element.rgb 0.5 0.5 0.5

    else
        Element.rgb 0 0 0


viewNewItem : Model -> Element.Element Msg
viewNewItem model =
    let
        isValid =
            String.length model.newItem > 3
    in
    Element.row [ Element.spacing 5, Element.width Element.fill ]
        [ Element.Input.text []
            { onChange = UpdateNewItem
            , text = model.newItem
            , placeholder =
                Just
                    (Element.Input.placeholder []
                        (Element.text "Add to your Todo List")
                    )
            , label = Element.Input.labelHidden "New Item"
            }
        , Element.Input.button
            ([ Element.padding 12, Element.Border.color (Element.rgb 0.8 0.8 0.8), Element.Border.width 1, Element.Border.rounded 2 ]
                ++ (if isValid then
                        [ Element.Background.color (Element.rgb 0.8 0.8 0.8) ]

                    else
                        []
                   )
            )
            { onPress =
                if isValid then
                    Just AddNewItem

                else
                    Nothing
            , label = Element.text "Add Item"
            }
        ]
