module Maunaloa.OptionPurchases exposing (..)

import Html as H
import Html.Attributes as A
import Common.ComboBox as CMB


view : String -> Maybe CMB.SelectItems -> H.Html Msg
view tickers =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ H.div [ A.class "col-sm-3" ]
                [ CMB.makeSelect "Tickers: " FetchOptions tickers selectedTicker ]
            ]
        ]
