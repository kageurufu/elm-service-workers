module Frontend exposing (main)

import Browser
import Browser.Navigation
import Effect
import Element
import Frontend.Ports
import Interop
import Json.Decode as Decode
import Json.Encode as Encode
import Pages
import Routes
import Serialize as S
import State.Shared exposing (SharedModel)
import Url


type alias Model =
    { sharedModel : SharedModel
    , page : Pages.Page
    , navKey : Browser.Navigation.Key
    , workerActive : Bool
    }


type Msg
    = SharedMsg State.Shared.SharedMsg
    | PageMsg Pages.PageMsg
    | Navigate Routes.Route
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | InteropError (S.Error Never)
    | InteropResponse Interop.Response
    | NoOp


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type alias Flags =
    { worker : Bool }


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map Flags
        (Decode.field "worker" Decode.bool)


init : Encode.Value -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flagsValue url key =
    let
        flags =
            flagsValue
                |> Decode.decodeValue flagsDecoder
                |> Result.withDefault (Flags False)

        sharedModel =
            State.Shared.init

        route =
            Routes.fromUrl url
    in
    ( { sharedModel = sharedModel
      , page = Pages.initPageModel route sharedModel
      , navKey = key
      , workerActive = flags.worker
      }
    , Cmd.none
    )


view : Model -> Browser.Document Msg
view model =
    { title = Pages.title model.page
    , body =
        [ Element.layout []
            (Pages.view model.sharedModel model.page
                |> Element.map PageMsg
            )
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SharedMsg sharedMsg ->
            if model.workerActive then
                ( model, Frontend.Ports.send (Interop.SharedMsg sharedMsg) )

            else
                let
                    ( sharedModel, sharedCmds ) =
                        State.Shared.update sharedMsg model.sharedModel
                in
                ( { model | sharedModel = sharedModel }, Cmd.map SharedMsg sharedCmds )

        InteropError err ->
            ( model, Cmd.none )

        InteropResponse (Interop.SharedModel sharedModel) ->
            ( { model | sharedModel = sharedModel }, Cmd.none )

        InteropResponse (Interop.RpcResult result) ->
            ( model, Cmd.none )

        Navigate route ->
            ( { model
                | page = Pages.initPageModel route model.sharedModel
              }
            , Cmd.none
            )

        PageMsg pageMsg ->
            let
                ( newPage, pageMsgs ) =
                    Pages.update pageMsg model.page model.sharedModel
            in
            ( { model | page = newPage }
            , pageMsgs
                |> Effect.map PageMsg
                |> Effect.toCmd
                    { key = model.navKey
                    , fromSharedMsg = SharedMsg
                    }
            )

        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        UrlChanged url ->
            let
                newRoute =
                    Routes.fromUrl url

                newPage =
                    Pages.initPageModel newRoute model.sharedModel
            in
            ( { model | page = newPage }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Frontend.Ports.onMessage
        InteropError
        InteropResponse
