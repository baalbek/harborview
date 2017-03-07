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


type Graphx
    = Line (List Float)
    | Bar (List Float)


type alias Graph =
    { lines : Maybe (List (List Float))
    , bars : Maybe (List (List Float))
    , candlesticks : Maybe (List Candlestick)
    }


type alias ChartInfo =
    { minDx : Date
    , xAxis : List Float
    , chart : Graph
    }



{-
   , lines : List (List Float)
   , candlesticks : Maybe (List Candlestick)
   , lines2 : Maybe (List (List Float))
-}


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
