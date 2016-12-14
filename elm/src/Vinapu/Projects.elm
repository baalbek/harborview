module Vinapu.Projects exposing (..)

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
import String
import Common.ModalDialog exposing (ModalDialog, dlgOpen, dlgClose, makeOpenDlgButton, modalDialog)
import Common.ComboBox
    exposing
        ( ComboBoxItem
        , SelectItems
        , comboBoxItemDecoder
        , comboBoxItemListDecoder
        , makeSelectOption
        , emptySelectOption
        , makeSelect
        , makeSimpleSelect
        , onChange
        , updateComboBoxItems
        )


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


mainUrl =
    "/vinapu"



-- "http://localhost:8082/vinapu"


makeOpenDlgButton' =
    makeOpenDlgButton "col-sm-3"



--"https://192.168.1.48/vinapu"
-- MODEL


type alias Model =
    { projects : Maybe SelectItems
    , locations : Maybe SelectItems
    , systems : Maybe SelectItems
    , nodes : Maybe SelectItems
    , elementLoads : Maybe String
    , dlgProj : ModalDialog
    , projName : String
    , dlgLoc : ModalDialog
    , locName : String
    , dlgSys : ModalDialog
    , sysName : String
    , dlgElement : ModalDialog
    , selectedProject : String
    , selectedLocation : String
    , selectedSystem : String
    }


initModel : Model
initModel =
    { projects = Nothing
    , locations = Nothing
    , systems = Nothing
    , nodes = Nothing
    , elementLoads = Nothing
    , dlgProj = dlgClose
    , projName = ""
    , dlgLoc = dlgClose
    , locName = ""
    , dlgSys = dlgClose
    , sysName = ""
    , dlgElement = dlgClose
    , selectedProject = "-1"
    , selectedLocation = "-1"
    , selectedSystem = "-1"
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
    | OnNewLocation Int
    | SysOpen
    | SysOk
    | SysCancel
    | SysNameChange String
    | OnNewSystem Int
    | ElementOpen
    | ElementOk
    | ElementCancel
    | ElementNameChange String



-- INIT


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchProjects )



-- UPDATE


emptyComboBoxItem : ComboBoxItem
emptyComboBoxItem =
    ComboBoxItem "-1" "-"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProjectsFetched s ->
            ( { model
                | projects = Just s
                , selectedLocation = "-1"
                , selectedSystem = "-1"
                , locations = Nothing
                , systems = Nothing
                , elementLoads = Nothing
              }
            , Cmd.none
            )

        FetchLocations s ->
            ( { model | selectedProject = s }, fetchLocations s )

        LocationsFetched s ->
            ( { model
                | locations = Just s
                , selectedLocation = "-1"
                , selectedSystem = "-1"
                , systems = Nothing
                , elementLoads = Nothing
              }
            , Cmd.none
            )

        FetchSystems s ->
            ( { model | selectedLocation = s }, fetchSystems s )

        SystemsFetched s ->
            ( { model | systems = Just s, elementLoads = Nothing }, Cmd.none )

        FetchElementLoads s ->
            ( { model | selectedSystem = s }, fetchElementLoads s )

        ElementLoadsFetched s ->
            ( { model | elementLoads = Just s }, Cmd.none )

        FetchFail s ->
            Debug.log s ( model, Cmd.none )

        ProjOpen ->
            ( { model | dlgProj = dlgOpen }, Cmd.none )

        ProjOk ->
            ( { model | dlgProj = dlgClose }, addNewProject model.projName )

        ProjCancel ->
            ( { model | dlgProj = dlgClose }, Cmd.none )

        ProjNameChange s ->
            ( { model | projName = s }, Cmd.none )

        OnNewProject newOid ->
            ( { model
                | projects = updateComboBoxItems newOid model.projName model.projects
                , locations = Nothing
                , systems = Nothing
                , elementLoads = Nothing
              }
            , Cmd.none
            )

        LocOpen ->
            ( { model | dlgLoc = dlgOpen }, Cmd.none )

        LocOk ->
            ( { model | dlgLoc = dlgClose }, addNewLocation model.selectedProject model.locName )

        LocCancel ->
            ( { model | dlgLoc = dlgClose }, Cmd.none )

        LocNameChange s ->
            ( { model | locName = s }, Cmd.none )

        OnNewLocation newOid ->
            ( { model
                | locations = updateComboBoxItems newOid model.locName model.locations
                , systems = Nothing
                , elementLoads = Nothing
              }
            , Cmd.none
            )

        SysOpen ->
            ( { model | dlgSys = dlgOpen }, Cmd.none )

        SysOk ->
            ( { model | dlgSys = dlgClose }, addNewSystem model.selectedLocation model.sysName )

        SysCancel ->
            ( { model | dlgSys = dlgClose }, Cmd.none )

        SysNameChange s ->
            ( { model | sysName = s }, Cmd.none )

        OnNewSystem newOid ->
            ( { model
                | systems = updateComboBoxItems newOid model.sysName model.systems
                , elementLoads = Nothing
              }
            , Cmd.none
            )

        ElementOpen ->
            ( { model | dlgElement = dlgOpen }, Cmd.none )

        ElementOk ->
            ( { model | dlgElement = dlgClose }, Cmd.none )

        ElementCancel ->
            ( { model | dlgElement = dlgClose }, Cmd.none )

        ElementNameChange s ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> H.Html Msg
view model =
    let
        elementLoadsTable =
            case model.elementLoads of
                Nothing ->
                    H.div [ A.class "col-sm-12" ] []

                Just elementLoadsContent ->
                    H.div [ A.class "col-sm-12", A.property "innerHTML" (JE.string elementLoadsContent) ] []
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ makeOpenDlgButton' "New project" ProjOpen
                , makeOpenDlgButton' "New location" LocOpen
                , makeOpenDlgButton' "New system" SysOpen
                , makeOpenDlgButton' "New element" ElementOpen
                ]
            , H.div [ A.class "row" ]
                [ makeSelect "Projects: " FetchLocations model.projects model.selectedProject
                , makeSelect "Locations: " FetchSystems model.locations model.selectedLocation
                , makeSelect "Systems: " FetchElementLoads model.systems model.selectedSystem
                ]
            , H.div [ A.class "row" ]
                [ elementLoadsTable
                ]
            , modalDialog "New project"
                model.dlgProj
                ProjOk
                ProjCancel
                [ H.input [ A.class "form-control", onChange ProjNameChange ] []
                ]
            , modalDialog ("New Location for Project id: " ++ model.selectedProject)
                model.dlgLoc
                LocOk
                LocCancel
                [ H.label [] [ H.text "Location name:" ]
                , H.input [ A.class "form-control", onChange LocNameChange ] []
                ]
            , modalDialog ("New System for Location id: " ++ model.selectedLocation)
                model.dlgSys
                SysOk
                SysCancel
                [ H.label [] [ H.text "System name:" ]
                , H.input [ A.class "form-control", onChange SysNameChange ] []
                ]
            , modalDialog ("New Element for System id: " ++ model.selectedSystem)
                model.dlgElement
                ElementOk
                ElementCancel
                [ H.label [] [ H.text "Element name:" ]
                , H.input [ A.class "form-control", onChange ElementNameChange ] []
                , makeSimpleSelect "Node 1: " model.nodes "-1"
                ]
            ]



-- COMMANDS


asHttpBody : List ( String, JE.Value ) -> Http.Body
asHttpBody lx =
    let
        x =
            JE.object lx
    in
        Http.string (JE.encode 0 x)


addNewDbItem : String -> List ( String, JE.Value ) -> (Int -> Msg) -> Cmd Msg
addNewDbItem urlAction params msg =
    let
        url =
            mainUrl ++ urlAction

        pnBody =
            asHttpBody params
    in
        Http.post Json.int url pnBody
            |> Task.mapError toString
            |> Task.perform FetchFail msg


addNewProject : String -> Cmd Msg
addNewProject pn =
    addNewDbItem "/newproject" [ ( "pn", JE.string pn ) ] OnNewProject


addNewLocation : String -> String -> Cmd Msg
addNewLocation pid loc =
    case String.toInt pid of
        Ok pidx ->
            addNewDbItem "/newlocation" [ ( "pid", JE.int pidx ), ( "loc", JE.string loc ) ] OnNewLocation

        Err errMsg ->
            Cmd.none


addNewSystem : String -> String -> Cmd Msg
addNewSystem loc sys =
    case String.toInt loc of
        Ok locx ->
            addNewDbItem "/newsystem" [ ( "loc", JE.int locx ), ( "sys", JE.string sys ) ] OnNewSystem

        Err errMsg ->
            Cmd.none



{-
   addNewElement : String -> String -> Cmd Msg
   addNewElement sys elname =
       case String.toInt sys of
           Ok sysx ->
               addNewDbItem "/newelement" [ ( "sys", JE.int sysx ), ( "elname", JE.string elname) ] OnNewElement

           Err errMsg ->
               Cmd.none
-}


fetchProjects : Cmd Msg
fetchProjects =
    fetchComboBoxItems ProjectsFetched (mainUrl ++ "/projects")


fetchLocations : String -> Cmd Msg
fetchLocations s =
    fetchComboBoxItems LocationsFetched (mainUrl ++ "/locations?oid=" ++ s)


type alias DualComboBoxList =
    { systems : List ComboBoxItem
    , nodes : List ComboBoxItem
    }


fetchSystemsx : String -> Result String DualComboBoxList
fetchSystemsx s =
    let
        myDecoder =
            Json.object2
                DualComboBoxList
                ("systems" := comboBoxItemListDecoder)
                ("nodes" := comboBoxItemListDecoder)
    in
        Json.decodeString myDecoder s


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
    let
        url =
            mainUrl ++ "/elementloads?oid=" ++ s
    in
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
