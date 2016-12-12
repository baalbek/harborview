module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA

import ChartCommon.Point exposing (Point)

{-|

    ppy : pixels pr y value 

-}

type alias VRuler =
    { ul : Point 
    , lr : Point 
    , ppy : Float
    , values : Maybe (List (List Float))
    }


calcValue : VRuler -> Float -> Float
calcValue ruler pix =
    20.2


calcPix : VRuler -> Float -> Float
calcPix ruler val =
    20.2


initVruler : Point -> Point -> VRuler
initVruler ul lr = 
    let 
        maxVal = 100.0
        h = lr.y - ul.y
        ppy = h / maxVal
    in
        VRuler ul lr ppy Nothing 

vruler : Point -> Point ->
