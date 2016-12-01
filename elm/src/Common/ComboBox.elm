module Common.ComboBox
    exposing
        ( ComboBoxItem
        , SelectItems
        , comboBoxItemDecoder
        , comboBoxItemListDecoder
        )

import Json.Decode as Json exposing ((:=))


type alias ComboBoxItem =
    { val : String
    , txt : String
    }


type alias SelectItems =
    List ComboBoxItem


comboBoxItemDecoder : Json.Decoder ComboBoxItem
comboBoxItemDecoder =
    Json.object2
        ComboBoxItem
        ("v" := Json.string)
        ("t" := Json.string)


comboBoxItemListDecoder : Json.Decoder (List ComboBoxItem)
comboBoxItemListDecoder =
    Json.list comboBoxItemDecoder
