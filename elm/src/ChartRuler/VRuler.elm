module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import ChartCommon as C exposing (Point, ChartValues)


{-|

    ppy : pixels pr y value

-}
type alias VRuler =
    { ul : Point
    , lr : Point
    , ppy : Float
    , minVal : Float
    , maxVal : Float
        -- , values : Maybe ChartValues
    }


calcValue : VRuler -> Float -> Float
calcValue ruler pix =
    20.2


calcPix : VRuler -> Float -> Float
calcPix ruler val =
    20.2

lines : VRuler -> List (S.Svg a)
lines vr = []

vruler : Point -> Point -> Maybe ChartValues -> VRuler
vruler ul lr cv =
    let
        ( minVal, maxVal ) =
            minMax cv

        valueSpan =
            maxVal - minVal

        h =
            lr.y - ul.y

        ppy =
            h / valueSpan
    in
        VRuler ul lr ppy minVal maxVal



-- (Just (C.ChartPoints [[]]))


minMax : Maybe ChartValues -> ( Float, Float )
minMax cv =
    case cv of
        Nothing ->
            ( 0.0, 100.0 )

        Just cv' ->
            ( 0.0, 100.0 )


