module Pages.Index exposing (..)

import Element
import State.Shared
import Effect exposing (Effect)


type alias Model =
    {}


type Msg
    = NoOp


init : State.Shared.SharedModel -> Model
init sharedModel =
    {}


title : Model -> String
title _ =
    "Index"


update : Msg -> Model -> State.Shared.SharedModel -> ( Model, Effect Msg )
update msg model sharedModel =
    case msg of
        NoOp ->
            ( model, Effect.none )


view : Model -> State.Shared.SharedModel -> Element.Element Msg
view pageModel sharedModel =
    Element.column []
        [ Element.el []
            (Element.text "Index goes here")
        , Element.row []
            [ Element.text "You might want to see your "
            , Element.link []
                { url = "/groceries"
                , label = Element.text "Grocery List"
                }
            ]
        ]
