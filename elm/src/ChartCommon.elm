module ChartCommon exposing (..)

import String

type alias Point =
    { x : Float
    , y : Float }

type alias Candlestick = 
    { opn : Float
    , hi : Float
    , lo : Float
    , cls : Float }

type ChartValues 
    = Candlesticks (List Candlestick)
    | ChartPoints (List (List Float))

