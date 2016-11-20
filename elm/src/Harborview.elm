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
-- mainUrl = "https://192.168.1.48/vinapu" 

-- MODEL

type alias ComboBoxItem = 
    { 
        val: String 
        , txt: String 
    }

type alias SelectItems = List ComboBoxItem 

type alias ModalDialog =
    {
        opacity : String
        , pointerEvents : String   
    }

dlgOpen : ModalDialog 
dlgOpen = ModalDialog "1" "auto"

dlgClose : ModalDialog 
dlgClose = ModalDialog "0" "none"

type alias Model = 
    { 
        projects          : Maybe SelectItems 
        , locations       : Maybe SelectItems 
        , systems         : Maybe SelectItems 
        , elementLoads    : String
        , selectedProject : String 
        , dlgProj         : ModalDialog
        , projName        : String 
        , dlgLoc          : ModalDialog
        , locName         : String 
    }


model : Model 
model =
    {
        projects = Nothing -- [ComboBoxItem 1 "One1", ComboBoxItem 2 "Two!"]
        , locations = Nothing
        , systems = Nothing
        , elementLoads = "<p>-</p>"
        , selectedProject = "-1"
        , dlgProj = dlgClose
        , projName = "" 
        , dlgLoc = dlgClose
        , locName = "" 
    }

-- MSG


type Msg
  = ProjectsFetched SelectItems 
    | FetchLocations String
    | LocationsFetched SelectItems 
    | FetchSystems String
    | SystemsFetched SelectItems 
    | FetchElementLoads String
    | ElementLoadsFetched String 
    | FetchFail String 
    | ProjOpen
    | ProjOk 
    | ProjCancel
    | ProjNameChange String
    | OnNewProject Int
    | LocOpen
    | LocOk 
    | LocCancel
    | LocNameChange String

-- INIT


init : ( Model, Cmd Msg )
init = (model, fetchProjects) 

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        ProjectsFetched s -> 
            ({ model | projects = Just s, locations = Nothing, systems = Nothing } , Cmd.none)
        FetchLocations s -> 
            ({ model | selectedProject = s }, fetchLocations s)
        LocationsFetched s -> 
            ({ model | locations = Just s, systems = Nothing } , Cmd.none)
        FetchSystems s -> 
            (model, fetchSystems s)
        SystemsFetched s -> 
            ({ model | systems = Just s }, Cmd.none)
        FetchElementLoads s -> 
            (model, fetchElementLoads s)
        ElementLoadsFetched s -> 
            ({ model | elementLoads = s }, Cmd.none)
        FetchFail s ->
            Debug.log s (model, Cmd.none)
        ProjOpen ->
            Debug.log "Button open"  ({ model | dlgProj = dlgOpen }, Cmd.none)
        ProjOk ->
            -- Debug.log "ProjOk" (model, Cmd.none)
            Debug.log "ProjOk" ({ model | dlgProj = dlgClose }, addNewProject model.projName)
        ProjCancel ->
            ({ model | dlgProj = dlgClose }, Cmd.none)
        ProjNameChange s -> 
            -- Debug.log s (model, Cmd.none)
            ({ model | projName = s }, Cmd.none)
        OnNewProject s -> 
            Debug.log (toString s) (model, Cmd.none)
        LocOpen ->
            Debug.log "Button open"  ({ model | dlgLoc = dlgOpen }, Cmd.none)
        LocOk ->
            ({ model | dlgLoc = dlgClose }, Cmd.none)
        LocCancel ->
            ({ model | dlgLoc = dlgClose }, Cmd.none)
        LocNameChange s -> 
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
            makeOpenDlgButton "New project" ProjOpen
            , makeOpenDlgButton "New location" LocOpen
            {-
            makeOpenDlgButton "New project" LocOpen
            , makeOpenDlgButton "New location" LocOpen
            , makeOpenDlgButton "New system" LocOpen
            -}
        ]
        , H.div [ A.class "row" ]
        [
            makeSelect "Projects: " "projects" FetchLocations model.projects 
            , makeSelect "Locations: " "locations" FetchSystems model.locations
            , makeSelect "Systems: " "systems" FetchElementLoads model.systems
        ]
        , H.div [ A.class "row" ]
        [
            H.div [ A.class "col-sm-12", A.property "innerHTML" (JE.string model.elementLoads) ] []
        ]
        , H.div [ A.class "modalDialog", A.style [ ("opacity", model.dlgProj.opacity), ("pointer-events", model.dlgProj.pointerEvents) ]]
        [
            H.div []
            [
                H.h4 [] [ H.text "New project" ]
                , H.input [ A.class "form-control", onChange ProjNameChange ] []
                , H.button [ A.class "btn btn-default", E.onClick ProjOk ] [ H.text "OK" ]
                , H.button [ A.class "btn btn-default", E.onClick ProjCancel ] [ H.text "Cancel" ]
            ]
        ]
        , H.div [ A.class "modalDialog", A.style [ ("opacity", model.dlgLoc.opacity), ("pointer-events", model.dlgLoc.pointerEvents) ]]
        [
            H.div []
            [
                H.h4 [] [H.text ("New Location for Project id: " ++ model.selectedProject) ]
                , H.label [ A.for "dlg2-name" ] [ H.text "Location name:" ]
                , H.input [ A.class "form-control", onChange LocNameChange ] []
                , H.button [ A.class "btn btn-default", E.onClick LocOk ] [ H.text "OK" ]
                , H.button [ A.class "btn btn-default", E.onClick LocCancel ] [ H.text "Cancel" ]
            ]
        ]
    ]

makeOpenDlgButton : String -> Msg -> VD.Node Msg
makeOpenDlgButton caption clickEvent = 
    H.div [ A.class "col-sm-4" ]
    [
        H.button [ A.class "btn btn-default", E.onClick clickEvent ] [ H.text caption ]
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
    
makeSelect : String -> String -> (String -> a) -> Maybe SelectItems -> VD.Node a
makeSelect caption myId msg payload = 
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
                , A.id myId
            ]
            px
        ]
    ]

onChange : (String -> a) -> VD.Property a 
onChange tagger =
  E.on "change" (Json.map tagger E.targetValue)

-- COMMANDS

addNewProject : String -> Cmd Msg
addNewProject pn =
    let url = mainUrl ++ "/newproject" 
        pnJson = JE.object [ ("pn", JE.string pn) ]
        pnBody = Http.string (JE.encode 0 pnJson) in
    Http.post Json.int url pnBody 
        |> Task.mapError toString 
        |> Task.perform FetchFail OnNewProject 

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

fetchSystems : String -> Cmd Msg
fetchSystems s = 
    fetchComboBoxItems SystemsFetched (mainUrl ++ "/systems?oid=" ++ s)

fetchComboBoxItems : (SelectItems -> Msg) -> String -> Cmd Msg
fetchComboBoxItems fn url = 
    Http.get comboBoxItemListDecoder url
        |> Task.mapError toString 
        |> Task.perform FetchFail fn 


fetchElementLoads : String -> Cmd Msg
fetchElementLoads s = 
    let url = mainUrl ++ "/elementloads?oid=" ++ s in
    Http.getString url
        |> Task.mapError toString 
        |> Task.perform FetchFail ElementLoadsFetched



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
