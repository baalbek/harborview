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
import Json.Decode as Json exposing (field)
import Html as H
import Html.Attributes as A
import Tuple exposing (first, second)
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
        makeSelectOption_ =
            makeSelectOption selected

        px =
            case payload of
                Just p ->
                    emptySelectOption :: List.map makeSelectOption_ p

                Nothing ->
                    []
    in
        H.span []
            [ H.label [] [ H.text caption ]
            , H.select
                [ onChange msg
                , A.class "form-control"
                ]
                px
            ]


makeSimpleSelect : Maybe SelectItems -> String -> VD.Node a
makeSimpleSelect payload selected =
    let
        makeSelectOption_ =
            makeSelectOption selected

        px =
            case payload of
                Just p ->
                    emptySelectOption :: List.map makeSelectOption_ p

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
makeFGRSelect : String -> String -> CM.ColXs -> Maybe SelectItems -> Maybe (String -> a) -> VD.Node a
makeFGRSelect id lbl cx payload onChangeEvent =
    let
        makeSelectOption_ =
            makeSelectOption "-1"

        px =
            case payload of
                Just p ->
                    emptySelectOption :: List.map makeSelectOption_ p

                Nothing ->
                    []

        cx_ =
            CM.colXs cx

        selectBlock =
            case onChangeEvent of
                Just onChangeEvent_ ->
                    [ H.select [ onChange onChangeEvent_, A.class "form-control", A.id id ]
                        px
                    ]

                Nothing ->
                    [ H.select [ A.class "form-control", A.id id ]
                        px
                    ]
    in
        H.div [ A.class "form-group row" ]
            [ H.label [ A.for id, A.class (first cx_) ] [ H.text lbl ]
            , H.div [ A.class (second cx_) ]
                selectBlock
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
    Json.map2
        ComboBoxItem
        (field "v" Json.string)
        (field "t" Json.string)


comboBoxItemListDecoder : Json.Decoder (List ComboBoxItem)
comboBoxItemListDecoder =
    Json.list comboBoxItemDecoder
