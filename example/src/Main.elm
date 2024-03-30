module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Events.Extra.Wheel as Wheel
import Phosphor exposing (IconWeight(..), toHtml, withSize, withSizeUnit, withClass)



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
    | Scrolling Float
    | Reset
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetWeight weight ->
            { model | weight = parseWeight weight }

        SetSize size ->
            { model | size = clamp 4 2000 (size |> String.toFloat |> Maybe.withDefault 128) }

        Scrolling deltaY ->
            { model | size = clamp 4 2000 (model.size - (deltaY * 0.2)) }

        Reset ->
            init

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
            , Wheel.onWheel (\event -> Scrolling event.deltaY)
            ]
            [ Html.node "style" [] [ text css ]
              , h2
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
                [ Phosphor.phosphorLogo Fill |> withSize 4 |> toHtml []
                , text "phosphor-elm"
                ]
            , div
                [ style "position" "fixed"
                , style "bottom" "0"
                , style "left" "0"
                , style "right" "0"
                , style "z-index" "1"
                , style "display" "flex"
                , style "gap" "16px"
                , style "justify-content" "center"
                , style "align-items" "center"
                , style "padding" "16px"
                , class "grid"
                ]
                [ select [ onInput SetWeight, style "height" "21px" ]
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
                , button
                    [ onClick Reset ]
                    [ text "Reset" ]
                ]
            , div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "gap" "0.5em"
                , style "font-size" fontSize
                , style "transition" "font-size 200ms ease"
                , style "padding" "0.25em"
                , style "color" "darkolivegreen"
                ]
                [ Phosphor.baseballHelmet model.weight |> withClass "grid-item" |> toHtml []
                , Phosphor.boxingGlove model.weight |> withClass "grid-item" |> toHtml []
                , Phosphor.boules model.weight |> withClass "grid-item" |> toHtml []
                -- [ Phosphor.bookBookmark model.weight |> toHtml []
                -- , Phosphor.cloudMoon model.weight |> toHtml []
                -- , Phosphor.flask model.weight |> toHtml []
                ]
            , div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "gap" "0.5em"
                , style "font-size" fontSize
                , style "transition" "font-size 200ms ease"
                , style "padding" "0.25em"
                , style "color" "palevioletred"
                ]
                [ Phosphor.beachBall model.weight |> withClass "grid-item" |> toHtml []
                , Phosphor.courtBasketball model.weight |> withClass "grid-item" |> toHtml []
                , Phosphor.footballHelmet model.weight |> withClass "grid-item" |> toHtml []
                -- [ Phosphor.mountains model.weight |> toHtml []
                -- , Phosphor.package model.weight |> toHtml []
                -- , Phosphor.snowflake model.weight |> toHtml []
                ]
            , div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "gap" "0.5em"
                , style "font-size" fontSize
                , style "transition" "font-size 200ms ease"
                , style "padding" "0.25em"
                , style "color" "steelblue"
                ]
                [ Phosphor.hockey model.weight |> withClass "grid-item" |> toHtml []
                , Phosphor.personSimpleSnowboard model.weight |> withClass "grid-item" |> toHtml []
                , Phosphor.sock model.weight |> withClass "grid-item" |> toHtml []
                -- [ Phosphor.sunglasses model.weight |> toHtml []
                -- , Phosphor.tShirt model.weight |> toHtml []
                -- , Phosphor.spiral model.weight |> toHtml []
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
        font-family: monospace;
    }

    h2 {
        color: darkgrey;
    }

    .grid-item {
        cursor: pointer;
        transition: transform 150ms ease, filter 200ms ease;
    }

    .grid-item:hover {
        transform: scale(1.25);
        filter: drop-shadow(0 0 32px currentColor);
    }

    .grid-item:active {
        transform: scale(1.4);
    }
    """
