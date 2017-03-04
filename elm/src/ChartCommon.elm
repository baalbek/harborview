module ChartCommon exposing (..)

import Svg.Attributes as SA
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


myStyle =
    SA.style "font: 12px/normal Helvetica, Arial;"


myStroke =
    SA.stroke "#cccccc"


type alias ChartInfo =
    { minDx : Date
    , xAxis : List Float
    , lines : List (List Float)
    , candlesticks : Maybe (List Candlestick)
    , lines2 : Maybe (List (List Float))
    }


type alias ChartLines =
    { minVal : Float
    , maxVal : Float
    , lines : List (List Float)
    }


type alias ChartInfoJs =
    { xaxis : List Float
    , chartLines : ChartLines
    , candlesticks : Maybe (List Candlestick)
    , chartLines2 : Maybe ChartLines
    , strokes : List String
    }
