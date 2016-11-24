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
import String


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


mainUrl =
    "http://localhost:8082/vinapu"



--"https://192.168.1.48/vinapu"
-- MODEL


type alias ComboBoxItem =
    { val : String
    , txt : String
    }


type alias SelectItems =
    List ComboBoxItem


type alias ModalDialog =
    { opacity : String
    , pointerEvents : String
    }


dlgOpen : ModalDialog
dlgOpen =
    ModalDialog "1" "auto"


dlgClose : ModalDialog
dlgClose =
    ModalDialog "0" "none"


type alias Model =
    { projects : Maybe SelectItems
    , locations : Maybe SelectItems
    , systems : Maybe SelectItems
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



-- INIT


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchProjects )



-- UPDATE


emptyComboBoxItem : ComboBoxItem
emptyComboBoxItem =
    ComboBoxItem "-1" "-"


updateComboBoxItems : Int -> String -> Maybe SelectItems -> Maybe SelectItems
updateComboBoxItems newOid newItemName curItems =
    let
        newOidStr =
            toString newOid

        newItem =
            ComboBoxItem newOidStr ("[" ++ newOidStr ++ "] " ++ newItemName ++ " (New)")
    in
        case curItems of
            Nothing ->
                Just [ newItem ]

            Just itemx ->
                Just (newItem :: itemx)


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
                [ makeOpenDlgButton "New project" ProjOpen
                , makeOpenDlgButton "New location" LocOpen
                , makeOpenDlgButton "New system" SysOpen
                , makeOpenDlgButton "New element" ElementOpen
                ]
            , H.div [ A.class "row" ]
                [ makeSelect "Projects: " FetchLocations model.projects Nothing
                , makeSelect "Locations: " FetchSystems model.locations (Just model.selectedLocation)
                , makeSelect "Systems: " FetchElementLoads model.systems Nothing
                ]
            , H.div [ A.class "row" ]
                [ elementLoadsTable
                ]
            , H.div [ A.class "modalDialog", A.style [ ( "opacity", model.dlgProj.opacity ), ( "pointer-events", model.dlgProj.pointerEvents ) ] ]
                [ H.div []
                    [ H.h4 [] [ H.text "New project" ]
                    , H.input [ A.class "form-control", onChange ProjNameChange ] []
                    , H.button [ A.class "btn btn-default", E.onClick ProjOk ] [ H.text "OK" ]
                    , H.button [ A.class "btn btn-default", E.onClick ProjCancel ] [ H.text "Cancel" ]
                    ]
                ]
            , H.div [ A.class "modalDialog", A.style [ ( "opacity", model.dlgLoc.opacity ), ( "pointer-events", model.dlgLoc.pointerEvents ) ] ]
                [ H.div []
                    [ H.h4 [] [ H.text ("New Location for Project id: " ++ model.selectedProject) ]
                    , H.label [ A.for "dlg2-name" ] [ H.text "Location name:" ]
                    , H.input [ A.class "form-control", A.id "dlg2-name", onChange LocNameChange ] []
                    , H.button [ A.class "btn btn-default", E.onClick LocOk ] [ H.text "OK" ]
                    , H.button [ A.class "btn btn-default", E.onClick LocCancel ] [ H.text "Cancel" ]
                    ]
                ]
            , H.div [ A.class "modalDialog", A.style [ ( "opacity", model.dlgSys.opacity ), ( "pointer-events", model.dlgSys.pointerEvents ) ] ]
                [ H.div []
                    [ H.h4 [] [ H.text ("New System for Location id: " ++ model.selectedLocation) ]
                    , H.label [ A.for "dlg3-name" ] [ H.text "System name:" ]
                    , H.input [ A.class "form-control", A.id "dlg3-name", onChange SysNameChange ] []
                    , H.button [ A.class "btn btn-default", E.onClick SysOk ] [ H.text "OK" ]
                    , H.button [ A.class "btn btn-default", E.onClick SysCancel ] [ H.text "Cancel" ]
                    ]
                ]
            , H.div [ A.class "modalDialog", A.style [ ( "opacity", model.dlgElement.opacity ), ( "pointer-events", model.dlgElement.pointerEvents ) ] ]
                [ H.div []
                    [ H.h4 [] [ H.text ("New Element for System id: " ++ model.selectedSystem) ]
                    , H.button [ A.class "btn btn-default", E.onClick ElementOk ] [ H.text "OK" ]
                    , H.button [ A.class "btn btn-default", E.onClick ElementCancel ] [ H.text "Cancel" ]
                    ]
                ]
            ]


makeOpenDlgButton : String -> Msg -> VD.Node Msg
makeOpenDlgButton caption clickEvent =
    H.div [ A.class "col-sm-3" ]
        [ H.button [ A.class "btn btn-default", E.onClick clickEvent ] [ H.text caption ]
        ]


makeSelectOption : Maybe String -> ComboBoxItem -> VD.Node a
makeSelectOption selected item =
    case selected of
        Nothing ->
            H.option
                [ A.value item.val
                ]
                [ H.text item.txt ]

        Just selected' ->
            H.option
                [ A.value item.val
                , A.selected (selected' == item.val)
                ]
                [ H.text item.txt ]


emptySelectOption : VD.Node a
emptySelectOption =
    H.option
        [ A.value "-1"
        ]
        [ H.text "-" ]


makeSelect : String -> (String -> a) -> Maybe SelectItems -> Maybe String -> VD.Node a
makeSelect caption msg payload selected =
    let
        makeSelectOption' =
            makeSelectOption selected

        px =
            case payload of
                Just p ->
                    emptySelectOption :: List.map makeSelectOption' p

                Nothing ->
                    []
    in
        H.div [ A.class "col-sm-4" ]
            [ H.span []
                [ H.label [] [ H.text caption ]
                , H.select
                    [ onChange msg
                    , A.class "form-control"
                    ]
                    px
                ]
            ]


onChange : (String -> a) -> VD.Property a
onChange tagger =
    E.on "change" (Json.map tagger E.targetValue)



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

        --  [ ( key, JE.string item ), ( "jax", JE.int 34) ]
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
