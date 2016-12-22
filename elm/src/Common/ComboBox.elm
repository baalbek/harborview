module Common.ComboBox
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

import VirtualDom as VD
import Json.Decode as Json exposing ((:=))
import Html as H
import Html.Attributes as A

import Common.Miscellaneous as CM exposing (onChange)

type alias ComboBoxItem =
    { val : String
    , txt : String
    }


type alias SelectItems =
    List ComboBoxItem


makeSelectOption : String -> ComboBoxItem -> VD.Node a
makeSelectOption selected item =
    H.option
        [ A.value item.val
        , A.selected (selected == item.val)
        ]
        [ H.text item.txt ]


emptySelectOption : VD.Node a
emptySelectOption =
    H.option
        [ A.value "-1"
        ]
        [ H.text "-" ]


makeSelect : String -> (String -> a) -> Maybe SelectItems -> String -> VD.Node a
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

makeSimpleSelect : Maybe SelectItems -> String -> VD.Node a
makeSimpleSelect payload selected =
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
        H.select
        [ A.class "form-control"
        ]
        px
        
{-|

    Makes a bootstrap form-group row with select 

-}
makeFGRSelect : String -> String -> CM.ColXs -> Maybe SelectItems -> VD.Node a
makeFGRSelect id lbl cx payload = 
    let
        makeSelectOption' =
            makeSelectOption "-1"

        px =
            case payload of
                Just p ->
                    emptySelectOption :: List.map makeSelectOption' p

                Nothing ->
                    []

        cx' = CM.colXs cx

    in
        H.div [ A.class "form-group row" ]
            [ H.label [ A.for id, A.class (fst cx') ] [ H.text lbl ]
            , H.div [ A.class (snd cx') ]
                [ H.select [ A.class "form-control", A.id id ]
                    px
                ]
            ]

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

comboBoxItemDecoder : Json.Decoder ComboBoxItem
comboBoxItemDecoder =
    Json.object2
        ComboBoxItem
        ("v" := Json.string)
        ("t" := Json.string)


comboBoxItemListDecoder : Json.Decoder (List ComboBoxItem)
comboBoxItemListDecoder =
    Json.list comboBoxItemDecoder
