module Pages exposing (..)

import Effect
import Element
import Element.Background
import Element.Font
import Pages.Groceries
import Pages.Index
import Pages.TodoList
import Routes exposing (Route)
import State.Shared exposing (SharedModel)


type Page
    = Index Pages.Index.Model
    | TodoList Pages.TodoList.Model
    | Groceries Pages.Groceries.Model
    | NotFound


type PageMsg
    = IndexMsg Pages.Index.Msg
    | GroceriesMsg Pages.Groceries.Msg
    | TodoListMsg Pages.TodoList.Msg


initPageModel : Route -> SharedModel -> Page
initPageModel route sharedModel =
    case route of
        Routes.Index ->
            Index (Pages.Index.init sharedModel)

        Routes.Groceries ->
            Groceries (Pages.Groceries.init sharedModel)

        Routes.Todo ->
            TodoList (Pages.TodoList.init sharedModel)

        Routes.NotFound ->
            NotFound


title : Page -> String
title page =
    case page of
        Index pageModel ->
            Pages.Index.title pageModel

        Groceries pageModel ->
            Pages.Groceries.title pageModel

        TodoList pageModel ->
            Pages.TodoList.title pageModel

        NotFound ->
            "Page Not Found"


view : SharedModel -> Page -> Element.Element PageMsg
view sharedModel page =
    layout sharedModel <|
        case page of
            Index pageModel ->
                Element.map IndexMsg (Pages.Index.view pageModel sharedModel)

            Groceries pageModel ->
                Element.map GroceriesMsg (Pages.Groceries.view pageModel sharedModel)

            TodoList pageModel ->
                Element.map TodoListMsg (Pages.TodoList.view pageModel sharedModel)

            NotFound ->
                Element.column []
                    [ Element.el [ Element.Font.size 24 ] (Element.text "Page Not Found")
                    , Element.link [] { url = "/", label = Element.text "Go home" }
                    ]


layout : SharedModel -> Element.Element msg -> Element.Element msg
layout sharedModel childView =
    Element.column [ Element.width Element.fill, Element.spacing 10 ]
        [ Element.row
            [ Element.width Element.fill
            , Element.padding 15
            , Element.Background.color (Element.rgb 0.8 0.8 0.8)
            , Element.Font.size 24
            , Element.spaceEvenly
            ]
            [ Element.text "Elm Workers"
            , Element.row [ Element.spacing 15 ]
                [ Element.link [] { url = "/groceries", label = Element.text "Groceries" }
                , Element.link [] { url = "/todo", label = Element.text "Todo List" }
                ]
            ]
        , Element.el [ Element.padding 15, Element.width Element.fill ] childView
        ]


update : PageMsg -> Page -> SharedModel -> ( Page, Effect.Effect PageMsg )
update msg model sharedModel =
    case ( msg, model ) of
        ( IndexMsg pageMsg, Index indexModel ) ->
            let
                ( newIndexModel, indexCmds ) =
                    Pages.Index.update pageMsg indexModel sharedModel
            in
            ( Index newIndexModel
            , Effect.map IndexMsg indexCmds
            )

        ( GroceriesMsg pageMsg, Groceries pageModel ) ->
            let
                ( newPageModel, pageCmds ) =
                    Pages.Groceries.update pageMsg pageModel sharedModel
            in
            ( Groceries newPageModel, Effect.map GroceriesMsg pageCmds )

        ( TodoListMsg pageMsg, TodoList pageModel ) ->
            let
                ( newPageModel, pageCmds ) =
                    Pages.TodoList.update pageMsg pageModel sharedModel
            in
            ( TodoList newPageModel, Effect.map TodoListMsg pageCmds )

        _ ->
            ( model, Effect.none )
