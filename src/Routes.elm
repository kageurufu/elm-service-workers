module Routes exposing (..)

import Element
import Url
import Url.Parser as Parser


type Route
    = Index
    | Groceries
    | Todo
    | NotFound


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Index Parser.top
        , Parser.map Groceries (Parser.s "groceries")
        , Parser.map Todo (Parser.s "todo")
        ]


toRoute : String -> Route
toRoute s =
    Url.fromString s
        |> Maybe.andThen (Parser.parse parser)
        |> Maybe.withDefault NotFound


fromUrl : Url.Url -> Route
fromUrl url =
    Parser.parse parser url
        |> Maybe.withDefault NotFound
