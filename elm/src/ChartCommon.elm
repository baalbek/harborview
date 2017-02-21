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


type alias ChartValues =
    Maybe (List Float)



{-
   type ChartValues
       = Candlesticks (List Candlestick)
       | ChartPoints (List (List Float))
-}


type alias ChartInfo =
    { minDx : Date
    , maxDx : Date
    , minVal : Float
    , maxVal : Float
    , xAxis : List Float
    , lines : List (List Float)
    , candlesticks : Maybe (List Candlestick)
    }
