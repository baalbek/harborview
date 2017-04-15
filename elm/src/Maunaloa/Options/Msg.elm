module Maunaloa.Options.Msg exposing (..)

import Http
import Common.ComboBox as CMB


type TickersMsg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | FetchOptions String


type OtherMsg
    = Noop


type Msg
    = MsgForTickers TickersMsg
    | MsgForOther OtherMsg
