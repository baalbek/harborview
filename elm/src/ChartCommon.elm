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
    , maxDx : Date
    , minVal : Float
    , maxVal : Float
    , xAxis : List Float
    , lines : List (List Float)
    , candlesticks : Maybe (List Candlestick)
    }


type alias ChartInfoJs =
    { xaxis : List Float
    , lines : List (List Float)
    , candlesticks : Maybe (List Candlestick)
    , strokes : List String
    , canvasId : String
    }
