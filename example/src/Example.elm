module Example exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Phosphor exposing (IconWeight(..), toHtml, withSize, withSizeUnit)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { weight: IconWeight
    , size: Float
    }


init : Model
init =
    Model Thin 128



-- UPDATE


type Msg
    = SetWeight String
    | SetSize String
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetWeight weight ->
            { model | weight = parseWeight weight }

        SetSize size ->
            { model | size = size |> String.toFloat |> Maybe.withDefault 128 }

        _ ->
            model


-- VIEW


view : Model -> Html Msg
view model =
    let
        fontSize = String.fromFloat model.size ++ "px"
    in
        div
            [ style "display" "grid"
            , style "place-content" "center"
            , style "height" "100vh"
            ]
            [ Html.node "style" [] [ text css ]
            , div
                [ style "position" "fixed"
                , style "top" "0"
                , style "left" "0"
                , style "right" "0"
                , style "z-index" "1"
                , style "display" "flex"
                , style "gap" "16px"
                , style "justify-content" "center"
                , style "align-items" "center"
                , style "padding" "16px"
                ]
                [ select [ onInput SetWeight ]
                    [ option [ value "thin" ] [ text "Thin "] 
                    , option [ value "light" ] [ text "Light "] 
                    , option [ value "regular" ] [ text "Regular "] 
                    , option [ value "bold" ] [ text "Bold "] 
                    , option [ value "fill" ] [ text "Fill "] 
                    , option [ value "duotone" ] [ text "Duotone "] 
                    ]
                , input
                    [ type_ "number"
                    , placeholder "Size"
                    , value <| String.fromFloat model.size
                    , onInput SetSize
                    ] []
                ]
            , div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "gap" "0.5em"
                , style "font-size" fontSize
                , style "padding" "0.25em"
                , style "color" "darkolivegreen"
                ]
                [ Phosphor.campfire model.weight |> toHtml []
                , Phosphor.cactus model.weight |> toHtml []
                , Phosphor.beerBottle model.weight |> toHtml []
                ]
            , div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "gap" "0.5em"
                , style "font-size" fontSize
                , style "padding" "0.25em"
                , style "color" "palevioletred"
                ]
                [ Phosphor.flyingSaucer model.weight |> toHtml []
                , Phosphor.handEye model.weight |> toHtml []
                , Phosphor.skull model.weight |> toHtml []
                ]
            , div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "gap" "0.5em"
                , style "font-size" fontSize
                , style "padding" "0.25em"
                , style "color" "steelblue"
                ]
                [ Phosphor.gameController model.weight |> toHtml []
                , Phosphor.sword model.weight |> toHtml []
                , Phosphor.strategy model.weight |> toHtml []
                ]
            ]


parseWeight : String -> IconWeight
parseWeight weight =
    case weight of
        "thin" ->
            Thin

        "light" ->
            Light
    
        "bold" ->
            Bold

        "fill" ->
            Fill

        "duotone" ->
            Duotone

        _ ->
            Regular

css =
    """
    body {
        background-color: whitesmoke;
        overflow: hidden;
    }

    .ph-icon {
        cursor: pointer;
        transition: transform 150ms ease, filter 200ms ease;
    }

    .ph-icon:hover {
        transform: scale(1.25);
        filter: drop-shadow(0 0 32px currentColor);
    }

    .ph-icon:active {
        transform: scale(1.4);
    }
    """
