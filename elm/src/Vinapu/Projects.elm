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
import Common.Miscellaneous as CM exposing (makeLabel, makeInput, onChange, makeFGRInput )
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
        , updateComboBoxItems
        , makeFGRSelect 
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


type alias DualComboBoxList =
    { first : List ComboBoxItem
    , second : List ComboBoxItem
    }

type alias TripleComboBoxList =
    { first : List ComboBoxItem
    , second : List ComboBoxItem
    , third : List ComboBoxItem
    }

type alias Model =
    { projects : Maybe SelectItems
    , deadloads : Maybe SelectItems
    , liveloads : Maybe SelectItems
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
    , dlgElementLoad : ModalDialog
    , selectedProject : String
    , selectedLocation : String
    , selectedSystem : String
    , plw : String
    , width : String
    , loadFactor1 : String
    , formFactor1 : String
    }


initModel : Model
initModel =
    { projects = Nothing
    , deadloads = Nothing
    , liveloads = Nothing
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
    , dlgElementLoad = dlgClose
    , selectedProject = "-1"
    , selectedLocation = "-1"
    , selectedSystem = "-1"
    , plw = "0.5"
    , width = "5.0"
    , loadFactor1 = "5.0"
    , formFactor1 = "1.0"
    }



-- MSG


type Msg
    = ProjectsFetched TripleComboBoxList
    | FetchLocations String
    | LocationsFetched SelectItems
    | FetchSystems String
    | SystemsFetched DualComboBoxList
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
    | ElementDescChange String
    | ElementLoadOpen
    | ElementLoadOk
    | ElementLoadCancel
    | PlwChange String
    | PlateWidthChange String

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
                | projects = Just s.first
                , deadloads = Just s.second
                , liveloads = Just s.third
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
            ( { model | systems = Just s.first, nodes = Just s.second, elementLoads = Nothing }, Cmd.none )

        -- Debug.log (toString s.nodes) ( model, Cmd.none )
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

        ElementDescChange s ->
            ( model, Cmd.none )

        PlwChange s ->
            ( model, Cmd.none )

        PlateWidthChange s ->
            ( model, Cmd.none )

        ElementLoadOpen ->
            ( model, Cmd.none )

        ElementLoadOk ->
            ( model, Cmd.none )
        
        ElementLoadCancel ->
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
                [ makeInput ProjNameChange
                ]
            , modalDialog ("New Location for Project id: " ++ model.selectedProject)
                model.dlgLoc
                LocOk
                LocCancel
                [ makeLabel "Location Name:"
                , makeInput LocNameChange
                ]
            , modalDialog ("New System for Location id: " ++ model.selectedLocation)
                model.dlgSys
                SysOk
                SysCancel
                [ makeLabel "System Name:"
                , makeInput SysNameChange
                ]
            , modalDialog ("New Element for System id: " ++ model.selectedSystem)
                model.dlgElement
                ElementOk
                ElementCancel
                [ H.ul [ A.class "nav nav-tabs" ]
                    [ H.li [ A.class "active" ]
                        [ H.a [ A.href "#geo1", A.attribute "data-toggle" "pill" ] 
                            [ H.text "Geometry" ]
                        ]
                    , H.li []
                        [ H.a [ A.href "#loads1", A.attribute "data-toggle" "pill" ] 
                            [ H.text "Loads" ]
                        ]
                    ]
                , H.div [ A.class "tab-content" ]
                    [ H.div [ A.id "geo1", A.class "tab-pane in active" ]
                        [ makeFGRInput ElementDescChange "id1" "Element desc:" "text" CM.CX39 Nothing
                        , makeFGRSelect "id2" "Node 1:" CM.CX39 model.nodes 
                        , makeFGRSelect "id3" "Node 2:" CM.CX39 model.nodes 
                        , makeFGRInput PlwChange "id4" "Load distribution factor:" "number" CM.CX66 (Just "0.5")
                        , makeFGRInput PlateWidthChange "id5" "Plate width:" "number" CM.CX66 (Just "4.0")
                        ]
                    , H.div [ A.id "loads1", A.class "tab-pane" ]
                        [ makeFGRSelect "id6" "Dead load:" CM.CX39 model.deadloads
                        , makeFGRInput PlateWidthChange "id7" "Load factor dead load:" "text" CM.CX66 (Just "1.0")
                        , makeFGRInput PlateWidthChange "id8" "Form factor dead load:" "text" CM.CX66 (Just "1.0")
                        , makeFGRSelect "id9" "Live load:" CM.CX39 model.liveloads
                        , makeFGRInput PlateWidthChange "id10" "Load factor live load:" "text" CM.CX66 (Just "1.0")
                        , makeFGRInput PlateWidthChange "id11" "Form factor live load:" "text" CM.CX66 (Just "1.0")
                        ]
                    ]
                ]
            {-
            , modalDialog "Element Load for Element id: " 
                model.dlgElementLoad
                ElementLoadOk
                ElementLoadCancel
                []
            --}
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


fetchProjects : Cmd Msg
fetchProjects =
    let
        myDecoder =
            Json.object3
                TripleComboBoxList
                ("projects" := comboBoxItemListDecoder)
                ("deadloads" := comboBoxItemListDecoder)
                ("liveloads" := comboBoxItemListDecoder)

        myUrl =
            (mainUrl ++ "/projects")
    in
        Http.get myDecoder myUrl
            |> Task.mapError toString
            |> Task.perform FetchFail ProjectsFetched



-- fetchComboBoxItems ProjectsFetched (mainUrl ++ "/projects")


fetchLocations : String -> Cmd Msg
fetchLocations s =
    fetchComboBoxItems LocationsFetched (mainUrl ++ "/locations?oid=" ++ s)


fetchSystems : String -> Cmd Msg
fetchSystems s =
    let
        myDecoder =
            Json.object2
                DualComboBoxList
                ("systems" := comboBoxItemListDecoder)
                ("nodes" := comboBoxItemListDecoder)

        myUrl =
            (mainUrl ++ "/systems?oid=" ++ s)
    in
        Http.get myDecoder myUrl
            |> Task.mapError toString
            |> Task.perform FetchFail SystemsFetched


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



{-
   dc : String -> DualComboBoxList-- Result String DualComboBoxList
   dc s =
       let
           myDecoder =
               Json.object2
               DualComboBoxList
                   ("projects" := comboBoxItemListDecoder)
                   ("loads" := comboBoxItemListDecoder)
           result = Json.decodeString myDecoder s
       in
           case result of
               Ok r -> r
               Err _ -> DualComboBoxList [ComboBoxItem "" ""] [ComboBoxItem "" ""]
-}
{-
   addNewElement : String -> String -> Cmd Msg
   addNewElement sys elname =
       case String.toInt sys of
           Ok sysx ->
               addNewDbItem "/newelement" [ ( "sys", JE.int sysx ), ( "elname", JE.string elname) ] OnNewElement

           Err errMsg ->
               Cmd.none
-}
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
