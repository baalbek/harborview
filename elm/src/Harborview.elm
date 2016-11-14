module Harborview exposing (..)

import Dict exposing (Dict)
import Http 
import Html as H 
import Html.Attributes as A 
import Html.App as App
import Html.Events as E 
import Debug
import Json.Decode as Json exposing ((:=))
import VirtualDom as VD
import Task


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL

type alias ComboBoxItem = 
    { 
        oid: Int
        , val: String 
    }

type alias What a =
    { x : a
      , s : String }

type alias SelectItems = List ComboBoxItem -- Dict String String

type alias ModelPayload = Maybe SelectItems 

type alias Model = 
    { 
        projects : ModelPayload 
        , sp : String 
        , locations : ModelPayload 
        , sl : String 
    }

model : Model 
model =
    {
        projects = Just [ComboBoxItem 1 "One1", ComboBoxItem 2 "Two!"]
        , sp = "1"
        , locations = Nothing
        , sl = "1" 
    }
{-
model : Model 
model =
    {
        projects = Just (Dict.fromList
        [ 
            ("1", "Project 1")
            , ("2", "Project 2")
            , ("3", "Project 3")
        ])
        , sp = "1"
        , locations = Nothing
        , sl = "1" 
    }
-}

-- MSG


type Msg
  = Noop String
    | FetchProjects String
    | ProjectsFetched String
    | FetchFail String 


-- INIT


init : ( Model, Cmd Msg )
init = (model, Cmd.none) 

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        FetchProjects s -> 
            (model , fetchProjects s)
            --Debug.log s ({ model | sp = s } , fetchProjects s)
        ProjectsFetched s -> 
            Debug.log "ProjectFetched" ({ model | sl = s }, Cmd.none)
        FetchFail s ->
            Debug.log s (model, Cmd.none)
        Noop _ ->
            (model, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


-- VIEW


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ] 
    [
        H.div [ A.class "row" ]
        [
            makeSelect "Projects: " FetchProjects model.projects 
            , makeSelect "Locations: " Noop model.locations
        ]
    ]

makeSelectOption : (String,String) -> VD.Node a
makeSelectOption (value, displayValue) = 
      H.option
        [ A.value value
        -- , A.selected (lang == favorite2)
        ]
        [ H.text displayValue ]


makeSelectOption2 : ComboBoxItem -> VD.Node a
makeSelectOption2 item = 
      H.option
        [ A.value (toString item.oid)
        ]
        [ H.text (item.val)]

makeSelect : String -> (String -> a) -> ModelPayload -> VD.Node a
makeSelect caption msg payload = 
    let px = case payload of 
                    Just p -> List.map makeSelectOption2 p -- (List.map makeSelectOption <| Dict.toList p)
                    Nothing -> [] in
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
            px
        ]
    ]

onChange : (String -> a) -> VD.Property a 
onChange tagger =
  E.on "change" (Json.map tagger E.targetValue)

-- COMMANDS

-- decodeString (list (object2 Sel ("oid" := int) ("value" := string))) x

comboBoxItemDecoder : Json.Decoder ComboBoxItem
comboBoxItemDecoder =
    Json.object2 
        ComboBoxItem
        ("oid" := Json.int)
        ("val" := Json.string)

comboBoxItemListDecoder : Json.Decoder (List ComboBoxItem)
comboBoxItemListDecoder = 
    Json.list comboBoxItemDecoder 

decodeProjects : Json.Decoder String 
decodeProjects =
    Json.at ["oid"] Json.string

fetchProjects : String -> Cmd Msg
fetchProjects s = 
    let url = "http://localhost:8082" in
    Http.get decodeProjects url
        |> Task.mapError toString 
        |> Task.perform FetchFail ProjectsFetched 

{--
(>>=) : Maybe a -> (a -> Maybe b) -> Maybe b
(>>=) = Maybe.andThen 

-- Custom event handler
onTimeUpdate : (Float -> a) -> Attribute a 
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)

-- A `Json.Decoder` for grabbing `event.target.currentTime`.
targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float

type alias Ord a = 
    { fromInt : Int -> a
    , toInt   : a -> Int }
--}
