module Pages.Groceries exposing (..)

import Dict
import Effect exposing (Effect)
import Element
import Element.Background
import Element.Border
import Element.Input
import State.Shared


type alias Model =
    { newItem : String
    }


type Msg
    = UpdateNewItem String
    | AddNewItem
    | RemoveItem String
    | UpdateItem String Int


init : State.Shared.SharedModel -> Model
init _ =
    { newItem = "" }


title : Model -> String
title _ =
    "Groceries"


update : Msg -> Model -> State.Shared.SharedModel -> ( Model, Effect Msg )
update msg model sharedModel =
    case msg of
        UpdateNewItem newItem ->
            ( { model | newItem = newItem }, Effect.none )

        AddNewItem ->
            ( { model | newItem = "" }, Effect.shared (State.Shared.AddGroceryItem model.newItem) )

        RemoveItem item ->
            ( model, Effect.shared (State.Shared.RemoveGroceryItem item) )

        UpdateItem item quantity ->
            ( model, Effect.shared (State.Shared.SetGroceryItemQuantity item quantity) )


view : Model -> State.Shared.SharedModel -> Element.Element Msg
view model sharedModel =
    Element.column [ Element.centerX, Element.spacing 15 ]
        [ viewGroceryList sharedModel
        , viewNewItem model
        ]


viewGroceryList : State.Shared.SharedModel -> Element.Element Msg
viewGroceryList sharedModel =
    Element.column [ Element.spacing 10, Element.width Element.fill ]
        (sharedModel.groceryList
            |> Dict.toList
            |> List.map
                (\( item, quantity ) ->
                    Element.row [ Element.width Element.fill, Element.spaceEvenly ]
                        [ Element.text item
                        , Element.row [ Element.spacing 5 ]
                            [ if quantity < 2 then
                                Element.Input.button []
                                    { onPress = Just (RemoveItem item)
                                    , label = Element.text "❌"
                                    }

                              else
                                Element.Input.button []
                                    { onPress = Just (UpdateItem item (quantity - 1))
                                    , label = Element.text "➖"
                                    }
                            , Element.text (String.fromInt quantity)
                            , Element.Input.button [] { onPress = Just (UpdateItem item (quantity + 1)), label = Element.text "➕" }
                            ]
                        ]
                )
        )


viewNewItem : Model -> Element.Element Msg
viewNewItem model =
    let
        isValid =
            String.length model.newItem < 3
    in
    Element.row [ Element.spacing 5 ]
        [ Element.Input.text []
            { onChange = UpdateNewItem
            , text = model.newItem
            , placeholder =
                Just
                    (Element.Input.placeholder []
                        (Element.text "Add to your Grocery List")
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
                    Nothing

                else
                    Just AddNewItem
            , label = Element.text "Add Item"
            }
        ]
