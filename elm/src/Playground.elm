module Playground exposing (..)

import Http
import Json.Decode as Json
import Json.Decode.Pipeline as JP


type alias A =
    { v : Int
    , x : Int
    }


aa =
    List.map (\x -> A x (2 * x)) (List.range 1 10)


swap : List A -> Int -> Int -> List A
swap lx oldVal newVal =
    let
        swapFn x =
            if x.v == oldVal then
                { x | v = newVal }
            else
                x
    in
        List.map swapFn lx



{-
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
           Http.send ChartsFetched <|
               Http.get url
                   myDecoder


   type alias Model =
       { street : String
       , city : String
       , houseNum : String
       }


   model : Model
   model =
       { street = "jax "
       , city = "San Francisco"
       , houseNum = "108"
       }


   type alias Address r =
       { r
           | street : String
       }


   alter : String -> Address r -> Address r
   alter s a =
       ({ a | street = s })


   peek : Model -> String
   peek m =
       m.city ++ " " ++ m.street ++ " " ++ m.houseNum


   unpackEither : String -> (String -> Result String a) -> a -> a
   unpackEither s f default =
       let
           x =
               f s
       in
           case x of
               Ok okx ->
                   okx

               Err _ ->
                   default

-}
