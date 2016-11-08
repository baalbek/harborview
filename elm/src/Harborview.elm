module Harborview exposing (..)

import Html as H 
import Html.Attributes as A 
import Html.App as App
import Html.Events as E 
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
  = Project String
    | Location String


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
            makeSelect "Projects: " Project
            , makeSelect "Locations: " Location
        ]
    ]

makeSelectOption : (String,String) -> VD.Node a
makeSelectOption (value, displayValue) = 
      H.option
        [ A.value value
        -- , A.selected (lang == favorite2)
        ]
        [ H.text displayValue ]

makeSelect : String -> (String -> a) -> VD.Node a
makeSelect caption msg = 
    H.div [ A.class "col-sm-4"]
    [ 
        H.span []
        [ 
            H.label [] [ H.text caption ]
            , H.select
            [   
                onChange msg 
                , A.class "form-control"
            ]
            []
            -- (List.map selectListOptions <| Dict.toList model.languages)
        ]
    ]

onChange : (String -> a) -> VD.Property a 
onChange tagger =
  E.on "change" (Json.map tagger E.targetValue)

(>>=) : Maybe a -> (a -> Maybe b) -> Maybe b
(>>=) = Maybe.andThen 

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
