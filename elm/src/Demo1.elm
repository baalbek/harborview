import Html exposing (..)
import Html.App exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))

type Msg
  = NoOp
  | FetchData
  | ErrorOccurred String
  | DataFetched (List RepoInfo)


type alias RepoInfo =
  { id : Int
  , name : String
  }

type alias Model =
  { message : String
  , repos : List RepoInfo
  }

main = Html.App.program
  { init = init
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

init =
  let
    model =
      { message = "Hello, Elm!"
      , repos = []
      }
  in
    model ! []
    
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []
    FetchData ->
      { model | message = "Initiating data fetch!" } ! [fetchData]
    ErrorOccurred errorMessage ->
      { model | message = "Oops! An error occurred: " ++ errorMessage } ! []
    DataFetched repos ->
      { model | repos = repos, message = "The data has been fetched!" } ! []

view : Model -> Html Msg
view model =
  let
    showRepo repo =
      li []
        [ text ("Repository ID: " ++ (toString repo.id) ++ "; ")
        , text ("Repository Name: " ++ repo.name)
        ]
  in
    div []
      [ div [] [ text model.message ]
      , button [ onClick FetchData ] [ text "Click to load nytimes repositories" ]
      , ul [] (List.map showRepo model.repos)
      ]

repoInfoDecoder : Json.Decoder RepoInfo
repoInfoDecoder =
  Json.object2
    RepoInfo
    ("id" := Json.int) 
    ("name" := Json.string) 

repoInfoListDecoder : Json.Decoder (List RepoInfo)
repoInfoListDecoder =
  Json.list repoInfoDecoder

fetchData : Cmd Msg
fetchData =
  Http.get repoInfoListDecoder "https://api.github.com/users/nytimes/repos"
    |> Task.mapError toString
    |> Task.perform ErrorOccurred DataFetched
