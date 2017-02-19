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


type alias ChartInfoBase =
    { minDx : Date
    , maxDx : Date
    , minVal : Float
    , maxVal : Float
    , xAxis : List Float
    }


type ChartInfo
    = ChartInfo1
        { base : ChartInfoBase
        , spots : Maybe (List Float)
        , itrend20 : Maybe (List Float)
        }
    | ChartInfo2
        { minVal : Float
        }


chartInfo1 :
    Date
    -> Date
    -> Float
    -> Float
    -> List Float
    -> Maybe (List Float)
    -> Maybe (List Float)
    -> ChartInfo
chartInfo1 minDx maxDx minVal maxVal x spots i20 =
    let
        base =
            ChartInfoBase minDx maxDx minVal maxVal x
    in
        ChartInfo1
            { base = base
            , spots = spots
            , itrend20 = i20
            }
