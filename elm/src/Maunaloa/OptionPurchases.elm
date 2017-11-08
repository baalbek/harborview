module Maunaloa.OptionPurchases exposing (..)

import Html as H
import Html.Attributes as A
import Common.ComboBox as CMB


-- region Init


mainUrl =
    "/maunaloa"


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


initModel : Model
initModel =
    {}


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- endregion
-- region TYPES


type Msg
    = NOOP


type alias Model =
    {}



-- endregion TYPES
-- region UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NOOP ->
            ( model, Cmd.none )



-- endregion
-- region VIEW


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        [ H.p [] [ H.text "Hi" ] ]



-- endregion
-- region COMMANDS
-- endregion
