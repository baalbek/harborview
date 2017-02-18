module Playground exposing (..)

import Http
import Json.Decode as Json
import Json.Decode.Pipeline as JP


type alias A =
    { v : Int }


initA =
    { v = 2 }


type B
    = B1 { v : Int }
    | B2 { v : Int }


type Msg
    = ChartsFetched (Result Http.Error B)


d2b : Int -> B
d2b v =
    B1 { v = v }


f1 : String -> Cmd Msg
f1 ticker =
    let
        myDecoder =
            JP.decode d2b
                |> JP.required "v" Json.int

        url =
            "/maunaloa/ticker?oid=" ++ ticker
    in
        Http.send ChartsFetched <| Http.get url myDecoder
