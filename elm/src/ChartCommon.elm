module ChartCommon exposing (..)

import String
import Date exposing (Date)


type alias Point =
    { x : Float
    , y : Float
    }


type alias Candlestick =
    { o : Float
    , h : Float
    , l : Float
    , c : Float
    }


type ChartValues
    = Candlesticks (List Candlestick)
    | ChartPoints (List (List Float))


type alias ChartInfo =
    { minDx : Date
    , maxDx : Date
    , xAxis : List Int
    , spots : Maybe (List Float)
    , itrend20 : Maybe (List Float)
    }
