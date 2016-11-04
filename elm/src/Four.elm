-- module Four exposing (..)
import Dict exposing (Dict)
import Html as H -- exposing (..)
import Html.App as App
import Html.Attributes as A -- exposing (value,selected)
import Html.Events as E -- exposing (..)
import Json.Decode as Json
import VirtualDom

main : Program Never 
main =
  App.beginnerProgram
    { model = model
    , update = update
    , view = view
    }
    
    
type alias Model =
  { languages : Dict String String
  , locations : Dict String String
  , favorite : Maybe String
  }
  
model : Model 
model =
  { languages = Dict.fromList
    [ (".cljs", "ClojureScript")
    , (".coffee", "CoffeeScript")
    , (".dart", "Dart")
    , (".elm", "Elm")
    , (".js", "JavaScript")
    , (".purs", "PureScript")
    , (".ts", "TypeScript")
    ]
  , locations = Dict.fromList
    [ ("1", "Etg 1")
    , ("2", "Etg 2")
    , ("3", "Etg 3")
    ]
  , favorite = Just "Elm"
  }
  
  
type Msg
  = SelectFavorite String
  
vxx = SelectFavorite "Joda"

update : Msg -> Model -> Model 
update msg model =
  case msg of
    SelectFavorite ext ->
      { model | favorite = Dict.get ext model.languages }
      
      
view : Model -> H.Html Msg
view model =
  let
    favorite =
      Maybe.withDefault "" model.favorite
  
    selectListOptions (ext, lang) =
      H.option
        [ A.value ext
        , A.selected (lang == favorite)
        ]
        [ H.text lang ]

  in
    H.div [ A.class "container" ] 
    [
        H.div [ A.class "row" ]
        [
            H.div [ A.class "col-sm-4"]
            [ 
                H.span []
                [ 
                    H.label [] [ H.text "Choose your favorite language: " ]
                    , H.select
                    [   
                        onChange SelectFavorite
                        , A.class "form-control"
                    ]
                    (List.map selectListOptions <| Dict.toList model.languages)
                ]
            ]
            , H.div [ A.class "col-sm-4"]
            [ 
                H.span []
                [ 
                    H.label [] [ H.text "Locations" ]
                    , H.select
                    [ 
                        onChange SelectFavorite
                        , A.class "form-control"
                    ]
                    (List.map selectListOptions <| Dict.toList model.locations)
                ]
            ]
        ]
        , H.p []
        [ 
            H.span [] 
            [ 
                H.text "Your favorite is: " 
            ]
            , H.strong [] 
            [ 
                H.text favorite
            ]
        ]
    ]

yax : String -> String
yax v = "Hi " ++ v 

onChange : (String -> a) -> VirtualDom.Property a 
onChange tagger =
  E.on "change" (Json.map tagger E.targetValue)

