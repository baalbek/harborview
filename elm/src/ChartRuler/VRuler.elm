module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA

import ChartCommon.Point exposing (Point)

{-|

    ppy : pixels pr y coordinate

-}
type alias InitRulerData =
    { minValue : Float
    , maxValue : Float
    , chartHeight : Float
    , ppy : Float
    }


type alias PointsRulerData =
    { points : List (List Float)
    , chartHeight : Float
    , ppy : Float
    }


type VRuler
    = InitVRuler InitRulerData
    | PointsVRuler PointsRulerData


calcValue : VRuler -> Float -> Float
calcValue ruler pix =
    20.2


calcPix : VRuler -> Float -> Float
calcPix ruler val =
    20.2


vruler : Float -> Float -> Float -> VRuler
vruler minVal maxVal chartH =
    InitVRuler (InitRulerData minVal maxVal chartH 22)
