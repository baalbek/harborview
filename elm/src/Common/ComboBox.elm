module Common.ComboBox
    exposing
        ( ComboBoxItem
        , SelectItems
        , comboBoxItemDecoder
        , comboBoxItemListDecoder
        , makeSelectOption 
        , emptySelectOption 
        , makeSelect 
        , onChange 
        , updateComboBoxItems 
        )

import VirtualDom as VD
import Json.Decode as Json exposing ((:=))
import Html as H
import Html.Attributes as A
import Html.Events as E


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

onChange : (String -> a) -> VD.Property a
onChange tagger =
    E.on "change" (Json.map tagger E.targetValue)

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
