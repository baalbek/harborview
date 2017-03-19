module Maunaloa.Options exposing (..)

import Html as H


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-------------------- PORTS ---------------------
-------------------- INIT ---------------------


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



------------------- MODEL ---------------------


type alias Model =
    {}


initModel : Model
initModel =
    {}



------------------- TYPES ---------------------


type Msg
    = Noop



-------------------- VIEW ---------------------


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        []



------------------- UPDATE --------------------


update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )



------------------ COMMANDS -------------------
---------------- SUBSCRIPTIONS ----------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
