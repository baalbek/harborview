module Maunaloa.Options.Model exposing (..)

import Common.ComboBox as CMB


type alias TickersModel =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    }


type alias Model =
    { tickerModel : TickersModel
    }
