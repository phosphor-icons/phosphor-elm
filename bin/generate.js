#!/usr/bin/env node
const fs = require("fs");
const { exec } = require("child_process");
const path = require("path");
const chalk = require("chalk");
const { parse } = require("svgson");

const { ASSETS_PATH, INDEX_PATH, TEST_PATH } = require("./index");

const icons = {};
const names = [];
const weights = ["thin", "light", "regular", "bold", "fill", "duotone"];

void (function main() {
  exec(
    "git submodule update --remote --init --force --recursive",
    (err, stdout, stderr) => {
      if (err) {
        console.error(`${chalk.inverse.red(" ERR ")} ${err.message}`);
        process.exit(1);
      }

      if (stderr) {
        console.error(`${chalk.inverse.red(" ERR ")} ${stderr}`);
        process.exit(1);
      }

      console.log(
        `${chalk.inverse.green(" OK ")} Updated submodule @phosphor-icons/core`
      );

      loadWeights();
      generateComponents()
        .then(generateTestPage)
        .catch((err) => {
          console.error(`${chalk.inverse.red(" ERR ")} ${err.message}`);
          process.exit(1);
        });
    }
  );
})();

function readFile(folder, name, weight) {
  const file = fs.readFileSync(folder);
  icons[name][weight] = file.toString("utf-8");
}

function loadWeights() {
  const weightFolder = fs.readdirSync(ASSETS_PATH, "utf-8");

  weightFolder.forEach((weightFolder) => {
    if (!fs.lstatSync(path.join(ASSETS_PATH, weightFolder)).isDirectory())
      return;

    if (!weights.includes(weightFolder)) {
      console.error(
        `${chalk.inverse.red(" ERR ")} Bad folder name ${weightFolder}`
      );
      process.exit(1);
    }

    const files = fs.readdirSync(path.join(ASSETS_PATH, weightFolder));
    files.forEach((filename) => {
      let name;
      const nameParts = filename.split(".svg")[0].split("-");
      if (nameParts[nameParts.length - 1] === weightFolder) {
        name = nameParts.slice(0, -1).join("-");
      } else {
        name = nameParts.join("-");
      }

      if (!icons[name]) {
        icons[name] = {};
      }
      const filepath = path.join(ASSETS_PATH, weightFolder, filename);
      readFile(filepath, name, weightFolder);
    });
  });
}

function checkFiles(icon) {
  const weightsPresent = Object.keys(icon);
  return (
    weightsPresent.length === 6 &&
    weightsPresent.every((w) => weights.includes(w))
  );
}

function generateAttrs(attributes) {
  return Object.entries(attributes).map(([attribute, value]) => {
    const attr = attribute.replace(/-./g, (x) => x[1].toUpperCase());
    return `A.${attr} "${value}"`;
  });
}

function generateElement(element, weight) {
  let childElements = element.children.map((child) =>
    generateElement(child, weight)
  );

  if (element.name === "svg") return `[ ${childElements.join(", ")} ]`;

  return `S.${element.name} [ ${generateAttrs(element.attributes).join(
    ", "
  )} ] [ ${childElements.join(", ")} ]`;
}

async function generateComponents() {
  let passes = 0;
  let fails = 0;

  const allIconNames = Object.keys(icons).map((i) =>
    i.replace(/-./g, (x) => x[1].toUpperCase())
  );

  let componentString = `\
module Phosphor exposing 
    ( Icon, IconWeight(..), IconVariant, toHtml
    , withClass, withSize, withSizeUnit
    , customIcon
    , ${allIconNames.join("\n    , ")}
    )

{-|


# Basic Usage

All icons have six weights; Regular, Thin, Light, Bold, Fill, and Duotone. Rendering an icon requires just a template and a weight:

    cube : Html msg
    cube =
        Phosphor.cube Bold
            |> Phosphor.toHtml []

Change \`Phosphor.cube\` to the icon you prefer, a list of all icons is visible here: <https://phosphoricons.com>

All icons of this package are provided as the internal type \`Icon\`. To turn them into an \`Html msg\`, simply use the \`toHtml\` function.

@docs Icon, IconWeight, IconVariant, toHtml


# Customize Icons

Phosphor Icons are \`1em\` by default, and come with the class \`ph-icon\`. For the aperture icon for example, this will be: \`ph-aperture\`.
To customize its class and size attributes simply use the \`withClass\` and \`withSize\` functions before turning them into Html with \`toHtml\`.

@docs withClass, withSize, withSizeUnit


# New Custom Icons

If you'd like to use same API while creating personally designed icons, you can use the \`customIcon\` function. You have to provide it with a \`List (Svg Never)\` that will be embedded into the icon.

@docs customIcon

# IconList

@docs ${allIconNames.join(", ")}

-}

import Html exposing (Html)
import Json.Encode
import Svg as S exposing (Svg, svg)
import Svg.Attributes as A
import VirtualDom


{-| Visual variant of the icon
-}
type IconWeight
    = Thin
    | Light
    | Regular
    | Bold
    | Fill
    | Duotone


{-| Customizable attributes of an icon
-}
type alias IconAttributes =
    { size : Float
    , sizeUnit : String
    , class : Maybe String
    }


{-| Default attributes of the icon
-}
defaultAttributes : IconAttributes
defaultAttributes =
    { size = 1
    , sizeUnit = "em"
    , class = Just "ph-icon"
    }


{-| Type representing icon builder
-}
type alias Icon =
    IconWeight -> IconVariant


{-| Opaque type representing builder output
-}
type IconVariant
    = IconVariant
        { attrs : IconAttributes
        , src : List (Svg Never)
        }


{-| Build custom svg icon

    [ Svg.line [ x1 "21", y1 "10", x2 "3", y2 "10" ]
    , Svg.line [ x1 "21", y1 "6", x2 "3", y2 "6" ]
    , Svg.line [ x1 "21", y1 "14", x2 "3", y2 "14" ]
    , Svg.line [ x1 "21", y1 "18", x2 "3", y2 "18" ]
    ]
        |> customIcon
        |> withSize 26
        |> withViewBox "0 0 26 26"
        |> toHtml []

Example output:
<svg xmlns="<http://www.w3.org/2000/svg"> width="26" height="26" viewBox="0 0 26 26" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="21" y1="10" x2="3" y2="10"></line><line x1="21" y1="6" x2="3" y2="6"></line><line x1="21" y1="14" x2="3" y2="14"></line><line x1="21" y1="18" x2="3" y2="18"></line></svg>
-}
customIcon : List (Svg Never) -> IconVariant
customIcon src =
    IconVariant
        { src = src
        , attrs = IconAttributes 1 "em" (Just "ph-icon custom")
        }


{-| Set size attribute of an icon

    Phosphor.download
        |> Phosphor.withSize 10
        |> Phosphor.toHtml []
-}
withSize : Float -> IconVariant -> IconVariant
withSize size (IconVariant { attrs, src }) =
    IconVariant { attrs = { attrs | size = size }, src = src }


{-| Set unit of size attribute of an icon, one of: "em", "ex", "px", "in", "cm", "mm", "pt", "pc", "%"

    Phosphor.download
        |> Phosphor.withSize 50
        |> Phosphor.withSizeUnit "%"
        |> Phosphor.toHtml []
-}
withSizeUnit : String -> IconVariant -> IconVariant
withSizeUnit sizeUnit (IconVariant { attrs, src }) =
    IconVariant { attrs = { attrs | sizeUnit = sizeUnit }, src = src }


{-| Overwrite class attribute of an icon

    Phosphor.download
        |> Phosphor.withClass "custom-clazz"
        |> Phosphor.toHtml []
-}
withClass : String -> IconVariant -> IconVariant
withClass class (IconVariant { attrs, src }) =
    IconVariant { attrs = { attrs | class = Just class }, src = src }


{-| Build and icon, ready to use in html. It accepts list of svg attributes, for example in case if you want to add an event handler.

    -- default
    Phosphor.download
        |> Phosphor.toHtml []

    -- with some attributes
    Phosphor.download
        |> Phosphor.withSize 10
        |> Phosphor.withClass "custom-clazz"
        |> Phosphor.toHtml [ onClick Download ]
-}
toHtml : List (S.Attribute msg) -> IconVariant -> Html msg
toHtml attributes (IconVariant { src, attrs }) =
    let
        strSize =
            attrs.size |> String.fromFloat

        baseAttributes =
            [ xmlns "http://www.w3.org/2000/svg"
            , A.fill "currentColor"
            , A.height <| strSize ++ attrs.sizeUnit
            , A.width <| strSize ++ attrs.sizeUnit
            , A.stroke "currentColor"
            , A.strokeLinecap "round"
            , A.strokeLinejoin "round"
            , A.viewBox "0 0 256 256"
            ]

        combinedAttributes =
            (case attrs.class of
                Just c ->
                    A.class c :: baseAttributes

                Nothing ->
                    baseAttributes
            )
                ++ attributes
    in
    src
        |> List.map (S.map never)
        |> svg combinedAttributes


xmlns : String -> S.Attribute a
xmlns s =
    VirtualDom.property "xmlns" <| Json.Encode.string s


makeBuilder : List (Svg Never) -> IconVariant
makeBuilder src =
    IconVariant { attrs = defaultAttributes, src = src }


`;

  for (let key in icons) {
    const icon = icons[key];
    const name = key.replace(/-./g, (x) => x[1].toUpperCase());
    names.push(name);

    if (!checkFiles(icon)) {
      fails += 1;
      console.error(
        `${chalk.inverse.red(" FAIL ")} ${name} is missing weights`
      );
      console.group();
      console.error(weights.filter((w) => !Object.keys(icon).includes(w)));
      console.groupEnd();
      continue;
    }

    componentString += `\
{-| ![${name}](https://raw.githubusercontent.com/phosphor-icons/phosphor-elm/master/assets/${key}/${key}.svg)
-}
${name} : Icon
${name} weight =
    let
        elements =
            case weight of
`;

    for (let weight in icon) {
      try {
        const svg = await parse(icon[weight]);
        // console.log(JSON.stringify(svg, null, 2));

        if (svg.name !== "svg") {
          console.error(`${chalk.inverse.red(" FAIL ")} ${name} is malformed`);
          console.group();
          console.error(`Root element was ${svg.name}`);
          console.groupEnd();
          fails += 1;
          continue;
        }

        const elmElementString = generateElement(svg);
        // console.log(elmElementString);

        componentString += `\
                ${weight.replace(/^\w/, (c) => c.toUpperCase())} ->
                    ${elmElementString}

`;
      } catch (err) {
        console.error(
          `${chalk.inverse.red(" FAIL ")} ${name} could not be parsed`
        );
        console.group();
        console.error(err);
        console.groupEnd();
        fails += 1;
      }
    }
    componentString += `\
    in
    makeBuilder elements


`;

    passes += 1;
    console.log(`${chalk.inverse.green(" DONE ")} ${name}`);
  }

  try {
    fs.writeFileSync(INDEX_PATH, componentString);
  } catch (err) {
    console.log(chalk.red(`Writing file failed`));
    console.group();
    console.error(err);
    console.groupEnd();
  }

  // TODO: implement logging with async writeFile()
  if (passes > 0)
    console.log(
      chalk.green(`${passes} component${passes > 1 ? "s" : ""} generated`)
    );
  if (fails > 0)
    console.log(chalk.red(`${fails} component${fails > 1 ? "s" : ""} failed`));
}

function generateTestPage() {
  const fileString = `\
module Test exposing (..)

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
    Model Thin 64



-- UPDATE


type Msg
    = SetWeight String
    | SetSize String
    | Reset
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetWeight weight ->
            { model | weight = parseWeight weight }

        SetSize size ->
            { model | size = clamp 4 2000 (size |> String.toFloat |> Maybe.withDefault 128) }

        Reset ->
            init

        _ ->
            model


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
        color: white;
        background-color: #35313D;
        font-family: monospace;
    }

    h2 {
        color: darkgrey;
    }

    .row {
        display: flex;
        justify-content: center;
        gap: 32px;
        margin: 32px;
    }
    """


-- VIEW


view : Model -> Html Msg
view model =
    let
        fontSize = String.fromFloat model.size ++ "px"
    in
        div
            [ style "font-size" fontSize ]
            [ Html.node "style" [] [ text css ]
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
${names
  .map(
    (name) =>
      `           , div [ class "row" ]
                [ Phosphor.${name} model.weight |> toHtml []
                , Phosphor.${name} Thin |> toHtml []
                , Phosphor.${name} Light |> toHtml []
                , Phosphor.${name} Regular |> toHtml []
                , Phosphor.${name} Bold |> toHtml []
                , Phosphor.${name} Fill |> toHtml []
                , Phosphor.${name} Duotone |> toHtml []
                ]`
  )
  .join("\n")}
            ]
`;
  fs.writeFileSync(TEST_PATH, fileString);
}
