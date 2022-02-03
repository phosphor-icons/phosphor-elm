#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const chalk = require("chalk");
const { parse } = require("svgson");

const { ASSETS_PATH, INDEX_PATH } = require("./index");

const icons = {};
const weights = ["Thin", "Light", "Regular", "Bold", "Fill", "Duotone"];

void (async function main() {
  readFiles();
  // console.log(
  //   Object.keys(icons).map((i) => i.replace(/-./g, (x) => x[1].toUpperCase()))
  // );
  await generateComponents();
})();

function readFile(folder, pathname, weight) {
  const file = fs.readFileSync(pathname);
  icons[folder][weight] = file
    .toString("utf-8")
    .replace(/^.*<\?xml.*?\>/g, "")
    .replace(
      /<rect width="25[\d,\.]+" height="25[\d,\.]+" fill="none".*?\/>/g,
      ""
    )
    .replace(/<title.*?/, "")
    .replace(/"#0+"/g, "currentColor");
}

function readFiles() {
  const folders = fs.readdirSync(ASSETS_PATH, "utf-8");

  folders.forEach((folder) => {
    if (!fs.lstatSync(path.join(ASSETS_PATH, folder)).isDirectory()) return;
    icons[folder] = {};

    const files = fs.readdirSync(path.join(ASSETS_PATH, folder));
    files.forEach((filename) => {
      const filepath = path.join(ASSETS_PATH, folder, filename);
      const weight = filename.split(".svg")[0].split("-").slice(-1)[0];
      switch (weight) {
        case "thin":
        case "light":
        case "bold":
        case "fill":
        case "duotone":
          readFile(
            folder,
            filepath,
            weight.replace(/^\w/, (c) => c.toUpperCase())
          );
          break;
        default:
          readFile(folder, filepath, "Regular");
          break;
      }
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
    // console.log([attribute, attr, value]);
    return `Svg.Attributes.${attr} "${value}"`;
  });
}

function generateElement(element, weight) {
  let childElements = element.children.map((child) =>
    generateElement(child, weight)
  );

  if (element.name === "svg") return `[ ${childElements.join(", ")} ]`;

  return `Svg.${element.name} [ ${generateAttrs(element.attributes).join(
    ", "
  )} ] [ ${childElements.join(", ")} ]`;
}

async function generateComponents() {
  let passes = 0;
  let fails = 0;

  let componentString = `\
module Phosphor exposing 
    ( Icon
    , IconVariant
    , IconWeight(..)
    , ${Object.keys(icons)
      .map((i) => i.replace(/-./g, (x) => x[1].toUpperCase()))
      .join("\n    , ")}
    , customIcon
    , defaultAttributes
    , toHtml
    , withClass
    , withSize
    , withSizeUnit
    , xmlns
    )

import Html exposing (Html)
import Json.Encode
import Svg exposing (Svg, svg)
import Svg.Attributes
import VirtualDom


type IconWeight
    = Thin
    | Light
    | Regular
    | Bold
    | Fill
    | Duotone


type alias IconAttributes =
    { size : Float
    , sizeUnit : String
    , class : Maybe String
    }


defaultAttributes : IconAttributes
defaultAttributes =
    { size = 1
    , sizeUnit = "em"
    , class = Just "ph-icon"
    }


type alias Icon =
    IconWeight -> IconVariant


type IconVariant
    = IconVariant
        { attrs : IconAttributes
        , src : List (Svg Never)
        }


customIcon : List (Svg Never) -> IconVariant
customIcon src =
    IconVariant
        { src = src
        , attrs = IconAttributes 1 "em" (Just "ph-icon custom")
        }


withSize : Float -> IconVariant -> IconVariant
withSize size (IconVariant { attrs, src }) =
    IconVariant { attrs = { attrs | size = size }, src = src }


withSizeUnit : String -> IconVariant -> IconVariant
withSizeUnit sizeUnit (IconVariant { attrs, src }) =
    IconVariant { attrs = { attrs | sizeUnit = sizeUnit }, src = src }


withClass : String -> IconVariant -> IconVariant
withClass class (IconVariant { attrs, src }) =
    IconVariant { attrs = { attrs | class = Just class }, src = src }


toHtml : List (Svg.Attribute msg) -> IconVariant -> Html msg
toHtml attributes (IconVariant { src, attrs }) =
    let
        strSize =
            attrs.size |> String.fromFloat

        baseAttributes =
            [ Svg.Attributes.fill "currentColor"
            , Svg.Attributes.height <| strSize ++ attrs.sizeUnit
            , Svg.Attributes.width <| strSize ++ attrs.sizeUnit
            , Svg.Attributes.stroke "currentColor"
            , Svg.Attributes.strokeLinecap "round"
            , Svg.Attributes.strokeLinejoin "round"
            , Svg.Attributes.viewBox "0 0 256 256"
            ]

        combinedAttributes =
            (case attrs.class of
                Just c ->
                    Svg.Attributes.class c :: baseAttributes

                Nothing ->
                    baseAttributes
            )
                ++ attributes
    in
    src
        |> List.map (Svg.map never)
        |> svg combinedAttributes


xmlns : String -> Svg.Attribute a
xmlns s =
    VirtualDom.property "xmlns" <| Json.Encode.string s


makeBuilder : List (Svg Never) -> IconVariant
makeBuilder src =
    IconVariant { attrs = defaultAttributes, src = src }  

`;

  let i = 0;

  for (let key in icons) {
    // if (i > 4) break;

    const icon = icons[key];
    const name = key.replace(/-./g, (x) => x[1].toUpperCase());

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
                ${weight} ->
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
    i += 1;
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
