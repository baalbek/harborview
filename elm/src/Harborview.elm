module Harborview exposing (..)

import Html as H 
import Html.Attributes as A 
import Html.App as App
import Html.Events exposing (on) 
import Debug
import Json.Decode as Json
import VirtualDom as VD

main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model = Int



-- MSG


type Msg
    = NoOp
    | TimeUpdate Float


-- INIT


init : ( Model, Cmd Msg )
init = (4, Cmd.none) 

-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Debug.log "Unknown message" ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Ord a = 
    { fromInt : Int -> a
    , toInt   : a -> Int }

-- VIEW


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ] 
    [
        H.div [ A.class "row" ]
        [
            makeSelect "Projects: "
            , makeSelect "Locations: "
        ]
    ]

makeSelect : String -> VD.Node a
makeSelect caption = 
    H.div [ A.class "col-sm-4"]
    [ 
        H.span []
        [ 
            H.label [] [ H.text caption ]
            , H.select
            [   
                -- onChange SelectFavorite
                A.class "form-control"
            ]
            []
            -- (List.map selectListOptions <| Dict.toList model.languages)
        ]
    ]

{--
-- Custom event handler
onTimeUpdate : (Float -> a) -> Attribute a 
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)

-- A `Json.Decoder` for grabbing `event.target.currentTime`.
targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float
--}
