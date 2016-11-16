module Harborview exposing (..)

import Dict exposing (Dict)
import Http 
import Html as H 
import Html.Attributes as A 
import Html.App as App
import Html.Events as E 
import Debug
import Json.Encode as JE 
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


mainUrl = "http://localhost:8082/vinapu"   
-- mainUrl = "https://192.168.1.48" 

-- MODEL

type alias ComboBoxItem = 
    { 
        val: String 
        , txt: String 
    }

type alias What a =
    { x : a
      , s : String }

type alias SelectItems = List ComboBoxItem -- Dict String String

type alias Model = 
    { 
        projects        : Maybe SelectItems 
        , locations     : Maybe SelectItems 
        , systems       : Maybe SelectItems 
        , elementLoads  : String
    }

model : Model 
model =
    {
        projects = Nothing -- [ComboBoxItem 1 "One1", ComboBoxItem 2 "Two!"]
        , locations = Nothing
        , systems = Nothing
        , elementLoads = "<p>-</p>"
    }

-- MSG


type Msg
  = ProjectsFetched SelectItems 
    | FetchLocations String
    | LocationsFetched SelectItems 
    | FetchSystems String
    | SystemsFetched SelectItems 
    | FetchElementLoads String
    | ElementLoadsFetched SelectItems 
    | FetchFail String 


-- INIT


init : ( Model, Cmd Msg )
init = (model, fetchProjects) 

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        ProjectsFetched s -> 
            Debug.log "ProjectFetched" ({ model | projects = Just s } , Cmd.none)
            -- Debug.log "ProjectFetched" ({ model | sl = s }, Cmd.none)
        FetchLocations s -> 
            Debug.log s (model, fetchLocations s)
        LocationsFetched s -> 
            Debug.log "LocationsFetched" ({ model | locations = Just s } , Cmd.none)
        FetchSystems s -> 
            Debug.log s (model, Cmd.none)
        SystemsFetched s -> 
            Debug.log "SystemsFetched" (model, Cmd.none)
        FetchElementLoads s -> 
            Debug.log s (model, Cmd.none)
        ElementLoadsFetched s -> 
            Debug.log "ElementLoadsFetched" (model, Cmd.none)
        FetchFail s ->
            Debug.log s (model, Cmd.none)


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
            makeSelect "Projects: " FetchLocations model.projects 
            , makeSelect "Locations: " FetchSystems model.locations
            , makeSelect "Systems: " FetchElementLoads model.systems
        ]
        , H.div [ A.class "row" ]
        [
            H.div [ A.class "col-sm-12", A.property "innerHTML" (JE.string model.elementLoads ) ] []
        ]
    ]

makeSelectOption : ComboBoxItem -> VD.Node a
makeSelectOption item = 
      H.option
        [ A.value item.val -- (toString item.val)
        ]
        [ H.text item.txt]

emptySelectOption : VD.Node a
emptySelectOption =
      H.option
        [ A.value "-1"
        ]
        [ H.text "-"]
    
makeSelect : String -> (String -> a) -> Maybe SelectItems -> VD.Node a
makeSelect caption msg payload = 
    let px = case payload of 
                    Just p -> emptySelectOption :: List.map makeSelectOption p 
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

comboBoxItemDecoder : Json.Decoder ComboBoxItem
comboBoxItemDecoder =
    Json.object2 
        ComboBoxItem
        ("v" := Json.string)
        ("t" := Json.string)

comboBoxItemListDecoder : Json.Decoder (List ComboBoxItem)
comboBoxItemListDecoder = 
    Json.list comboBoxItemDecoder 

fetchProjects : Cmd Msg
fetchProjects = 
    fetchComboBoxItems ProjectsFetched (mainUrl ++ "/projects")

fetchLocations : String -> Cmd Msg
fetchLocations s = 
    fetchComboBoxItems LocationsFetched (mainUrl ++ "/locations?oid=" ++ s)

fetchComboBoxItems : (SelectItems -> Msg) -> String -> Cmd Msg
fetchComboBoxItems fn url = 
    Http.get comboBoxItemListDecoder url
        |> Task.mapError toString 
        |> Task.perform FetchFail fn 






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
