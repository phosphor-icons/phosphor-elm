module Generate exposing (main)

{-| -}

import Dict
import Elm exposing (Declaration)
import Elm.Annotation as Annotation exposing (Annotation)
import Elm.Arg as Arg
import Elm.Declare
import Elm.Let
import Elm.Op
import Gen.Basics
import Gen.CodeGen.Generate as Generate
import Gen.Debug
import Gen.Html as Html
import Gen.Json.Encode
import Gen.List
import Gen.Maybe
import Gen.String
import Gen.Svg as Svg
import Gen.Svg.Attributes as SvgA
import Gen.VirtualDom as VirtualDom
import Json.Encode
import List.Extra
import Result.Extra
import String.Extra
import String.Multiline
import XmlParser


main : Program Json.Encode.Value () ()
main =
    Generate.fromDirectory file


file : Generate.Directory -> List Elm.File
file directory =
    mainModule directory
        :: assets directory
        :: perWeight directory


mainModule : Generate.Directory -> Elm.File
mainModule directory =
    Elm.fileWith [ "Phosphor" ]
        { docs = ""
        , aliases =
            [ ( [ "Svg" ], "S" )
            , ( [ "Svg", "Attributes" ], "A" )
            ]
        }
        [ Elm.docs
            (String.Multiline.here """
          # Basic Usage

          All icons have six weights; Regular, Thin, Light, Bold, Fill, and Duotone. Rendering an icon requires just a template and a weight:

              cube : Html msg
              cube =
                  Phosphor.cube Bold
                      |> Phosphor.toHtml []

          Change `Phosphor.cube` to the icon you prefer, a list of all icons is visible here: <https://phosphoricons.com>

          All icons of this package are provided as the internal type `Icon`. To turn them into an `Html msg`, simply use the `toHtml` function.
      """)
        , [ iconAlias.declaration
          , iconWeightType.declaration
          , iconVariantType
          , toHtml.declaration
          ]
            |> Elm.group
            |> Elm.expose
        , iconAttributesAlias
        , defaultAttributes.declaration
        , xmlns.declaration
        , Elm.docs
            (String.Multiline.here
                """
          # Customize Icons

          Phosphor Icons are `1em` by default, and come with the class `ph-icon`. For the aperture icon for example, this will be: `ph-aperture`.
          To customize its class and size attributes simply use the `withClass` and `withSize` functions before turning them into Html with `toHtml`.
          """
            )
        , [ withClass.declaration
          , withSize.declaration
          , withSizeUnit.declaration
          ]
            |> Elm.group
            |> Elm.expose
        , Elm.docs
            (String.Multiline.here
                """
          # New Custom Icons
          If you'd like to use same API while creating personally designed icons, you can use the `customIcon` function. You have to provide it with a `List (Svg Never)` that will be embedded into the icon.
          """
            )
        , Elm.expose (Elm.group [ customIcon ])
        , Elm.docs "# IconList"
        , makeBuilder.declaration
        , iconList directory
            |> Elm.group
            |> Elm.expose
        ]


type alias IconWeightRecord =
    { thin : Elm.Expression
    , light : Elm.Expression
    , regular : Elm.Expression
    , bold : Elm.Expression
    , fill : Elm.Expression
    , duotone : Elm.Expression
    }


iconWeightType : Elm.Declare.CustomType IconWeightRecord
iconWeightType =
    Elm.Declare.customTypeAdvanced "IconWeight"
        { exposeConstructor = True }
        IconWeightRecord
        |> Elm.Declare.variant0 "Thin" .thin
        |> Elm.Declare.variant0 "Light" .light
        |> Elm.Declare.variant0 "Regular" .regular
        |> Elm.Declare.variant0 "Bold" .bold
        |> Elm.Declare.variant0 "Fill" .fill
        |> Elm.Declare.variant0 "Duotone" .duotone
        |> Elm.Declare.finishCustomType
        |> Elm.Declare.withDocumentation "Visual variant of the icon"


iconAttributesAlias : Declaration
iconAttributesAlias =
    Annotation.record
        [ ( "size", Annotation.float )
        , ( "sizeUnit", Annotation.string )
        , ( "class", Annotation.maybe Annotation.string )
        ]
        |> Elm.alias "IconAttributes"
        |> Elm.withDocumentation "Customizable attributes of an icon"


defaultAttributes : Elm.Declare.Value
defaultAttributes =
    Elm.record
        [ ( "size", Elm.int 1 )
        , ( "sizeUnit", Elm.string "em" )
        , ( "class", Elm.maybe (Just (Elm.string "ph-icon")) )
        ]
        |> Elm.withType (Annotation.named [] "IconAttributes")
        |> Elm.Declare.value "defaultAttributes"
        |> Elm.Declare.withDocumentation "Default attributes of the icon"


iconAlias : Elm.Declare.Annotation
iconAlias =
    Annotation.function
        [ Annotation.named [] "IconWeight"
        ]
        (Annotation.named [] "IconVariant")
        |> Elm.Declare.alias "Icon"
        |> Elm.Declare.withDocumentation "Type representing icon builder"


iconVariantType : Declaration
iconVariantType =
    Elm.customType
        "IconVariant"
        [ Elm.variantWith "IconVariant"
            [ Annotation.record
                [ ( "attrs", Annotation.named [] "IconAttributes" )
                , ( "src", Annotation.list svgNever )
                ]
            ]
        ]
        |> Elm.withDocumentation "Opaque type representing builder output"


svgNever : Annotation
svgNever =
    Svg.annotation_.svg Gen.Basics.annotation_.never


customIcon : Declaration
customIcon =
    Elm.fn
        (Arg.varWith "src" (Annotation.list svgNever))
        (\src ->
            makeIconVariant
                { src = src
                , attrs =
                    Elm.apply (Elm.val "IconAttributes")
                        [ Elm.int 1
                        , Elm.string "em"
                        , Elm.maybe (Just (Elm.string "ph-icon custom"))
                        ]
                }
        )
        |> Elm.declaration "customIcon"
        |> Elm.withDocumentation
            (String.Multiline.here
                """
                Build custom svg icon

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
                <svg xmlns="<http://www.w3.org/2000/svg"> width="26" height="26" viewBox="0 0 26 26" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="21" y1="10" x2="3" y2="10"></line><line x1="21" y1="6" x2="3" y2="6"></line><line x1="21" y1="14" x2="3" y2="14"></line><line x1="21" y1="18" x2="3" y2="18"></line></svg>"""
            )


makeIconVariant : { src : Elm.Expression, attrs : Elm.Expression } -> Elm.Expression
makeIconVariant { src, attrs } =
    Elm.apply
        (Elm.value
            { importFrom = [ "Phosphor" ]
            , name = "IconVariant"
            , annotation = Nothing
            }
        )
        [ Elm.record
            [ ( "attrs", attrs )
            , ( "src", src )
            ]
        ]
        |> Elm.withType (Annotation.named [ "Phosphor" ] "IconVariant")


withSize : Elm.Declare.Function (Elm.Expression -> Elm.Expression -> Elm.Expression)
withSize =
    Elm.Declare.fn2 "withSize"
        (Arg.varWith "size" Annotation.float)
        iconVariantArg
        (\size { attrs, src } ->
            makeIconVariant
                { attrs = attrs |> Elm.updateRecord [ ( "size", size ) ]
                , src = src
                }
        )
        |> Elm.Declare.withDocumentation
            (String.Multiline.here
                """
                Set size attribute of an icon

                    Phosphor.download
                        |> Phosphor.withSize 10
                        |> Phosphor.toHtml []
                """
            )


withClass : Elm.Declare.Function (Elm.Expression -> Elm.Expression -> Elm.Expression)
withClass =
    Elm.Declare.fn2 "withClass"
        (Arg.varWith "class" Annotation.string)
        iconVariantArg
        (\class { attrs, src } ->
            makeIconVariant
                { src = src
                , attrs = attrs |> Elm.updateRecord [ ( "class", Elm.maybe (Just class) ) ]
                }
        )
        |> Elm.Declare.withDocumentation
            (String.Multiline.here
                """
                Overwrite class attribute of an icon

                    Phosphor.download
                        |> Phosphor.withClass "custom-clazz"
                        |> Phosphor.toHtml []
                """
            )


withSizeUnit : Elm.Declare.Function (Elm.Expression -> Elm.Expression -> Elm.Expression)
withSizeUnit =
    Elm.Declare.fn2 "withSizeUnit"
        (Arg.varWith "sizeUnit" Annotation.string)
        iconVariantArg
        (\sizeUnit { attrs, src } ->
            makeIconVariant
                { src = src
                , attrs = attrs |> Elm.updateRecord [ ( "sizeUnit", Elm.maybe (Just sizeUnit) ) ]
                }
        )
        |> Elm.Declare.withDocumentation
            (String.Multiline.here
                """
                Set unit of size attribute of an icon, one of: "em", "ex", "px", "in", "cm", "mm", "pt", "pc", "%"

                    Phosphor.download
                        |> Phosphor.withSize 50
                        |> Phosphor.withSizeUnit "%"
                        |> Phosphor.toHtml []
                """
            )


toHtml : Elm.Declare.Function (Elm.Expression -> Elm.Expression -> Elm.Expression)
toHtml =
    Elm.Declare.fn2 "toHtml"
        (Arg.varWith "attributes" (Annotation.list (Svg.annotation_.attribute (Annotation.var "msg"))))
        iconVariantArg
        (\attributes { attrs, src } ->
            Elm.Let.letIn identity
                |> Elm.Let.value "strSize"
                    (Gen.String.call_.fromFloat (Elm.get "size" attrs))
                |> Elm.Let.withBody
                    (\strSize ->
                        Elm.Let.letIn identity
                            |> Elm.Let.value "baseAttributes"
                                (Elm.list
                                    [ xmlns.call (Elm.string "http://www.w3.org/2000/svg")
                                    , SvgA.fill "currentColor"
                                    , SvgA.call_.height <| Elm.Op.append strSize (Elm.get "sizeUnit" attrs)
                                    , SvgA.call_.width <| Elm.Op.append strSize (Elm.get "sizeUnit" attrs)
                                    , SvgA.stroke "currentColor"
                                    , SvgA.strokeLinecap "round"
                                    , SvgA.strokeLinejoin "round"
                                    , SvgA.viewBox "0 0 256 256"
                                    ]
                                )
                            |> Elm.Let.withBody
                                (\baseAttributes ->
                                    Elm.Let.letIn
                                        identity
                                        |> Elm.Let.value "combinedAttributes"
                                            (Gen.Maybe.caseOf_.maybe (Elm.get "class" attrs)
                                                { just = \c -> Elm.Op.append (Elm.Op.cons (SvgA.call_.class c) baseAttributes) attributes
                                                , nothing = Elm.Op.append baseAttributes attributes
                                                }
                                            )
                                        |> Elm.Let.withBody
                                            (\combinedAttributes ->
                                                src
                                                    |> Elm.Op.pipe
                                                        (Elm.apply Gen.List.values_.map
                                                            [ Elm.apply Svg.values_.map [ Gen.Basics.values_.never ] ]
                                                        )
                                                    |> Elm.Op.pipe (Elm.apply Svg.values_.svg [ combinedAttributes ])
                                                    |> Elm.withType (Html.annotation_.html (Annotation.var "msg"))
                                            )
                                )
                    )
        )
        |> Elm.Declare.withDocumentation
            (String.Multiline.here
                """
                Build and icon, ready to use in html. It accepts list of svg attributes, for example in case if you want to add an event handler.

                    -- default
                    Phosphor.download
                        |> Phosphor.toHtml []

                    -- with some attributes
                    Phosphor.download
                        |> Phosphor.withSize 10
                        |> Phosphor.withClass "custom-clazz"
                        |> Phosphor.toHtml [ onClick Download ]
                """
            )


xmlns : Elm.Declare.Function (Elm.Expression -> Elm.Expression)
xmlns =
    Elm.Declare.fn "xmlns"
        (Arg.varWith "s" Annotation.string)
        (\s ->
            VirtualDom.property "xmlns" (Gen.Json.Encode.call_.string s)
                |> Elm.withType (Svg.annotation_.attribute (Annotation.var "msg"))
        )


iconVariantArg : Elm.Arg { attrs : Elm.Expression, src : Elm.Expression }
iconVariantArg =
    Arg.customTypeWith
        { importFrom = [ "Phosphor" ]
        , variantName = "IconVariant"
        , typeName = "IconVariant"
        }
        identity
        |> Arg.item
            (Arg.record
                (\src attrs ->
                    { attrs = attrs
                    , src = src
                    }
                )
                |> Arg.field "src"
                |> Arg.field "attrs"
            )


makeBuilder : Elm.Declare.Function (Elm.Expression -> Elm.Expression)
makeBuilder =
    Elm.Declare.fn "makeBuilder"
        (Arg.varWith "src"
            (Annotation.list (Svg.annotation_.svg Gen.Basics.annotation_.never))
        )
        (\src ->
            makeIconVariant
                { src = src
                , attrs = defaultAttributes.value
                }
        )


iconList : Generate.Directory -> List Declaration
iconList (Generate.Directory directory) =
    directory.directories
        |> Dict.toList
        |> List.concatMap
            (\( _, Generate.Directory icons ) ->
                icons.files
                    |> Dict.toList
                    |> List.map (\( filename, _ ) -> toIconName filename)
            )
        |> List.Extra.unique
        |> List.sort
        |> List.map
            (\iconName ->
                Elm.fn
                    (Arg.var "weight")
                    (\weight ->
                        Elm.Let.letIn identity
                            |> Elm.Let.value "elements"
                                (iconWeightType.case_ weight
                                    { bold = assetName iconName "Bold"
                                    , duotone = assetName iconName "Duotone"
                                    , fill = assetName iconName "Fill"
                                    , light = assetName iconName "Light"
                                    , regular = assetName iconName "Regular"
                                    , thin = assetName iconName "Thin"
                                    }
                                )
                            |> Elm.Let.withBody makeBuilder.call
                    )
                    |> Elm.withType iconAlias.annotation
                    |> Elm.declaration iconName
                    |> Elm.withDocumentation
                        (iconLink (String.Extra.dasherize iconName ++ ".svg") "regular")
            )


assetName : String -> String -> Elm.Expression
assetName iconName weight =
    Elm.value
        { importFrom = [ "Phosphor", "Assets" ]
        , name =
            case String.Extra.toSentenceCase weight of
                "Regular" ->
                    iconName

                capitalWeight ->
                    iconName ++ capitalWeight
        , annotation = Nothing
        }


perWeight : Generate.Directory -> List Elm.File
perWeight (Generate.Directory directory) =
    directory.directories
        |> Dict.toList
        |> List.map
            (\( weight, Generate.Directory icons ) ->
                icons.files
                    |> Dict.toList
                    |> List.map
                        (\( filename, _ ) ->
                            let
                                iconName : String
                                iconName =
                                    toIconName filename
                            in
                            assetName iconName weight
                                |> makeBuilder.call
                                |> Elm.withType (Annotation.named [ "Phosphor" ] "Icon")
                                |> Elm.declaration iconName
                                |> Elm.withDocumentation (iconLink filename weight)
                        )
                    |> (::) makeBuilder.declaration
                    |> Elm.file [ "Phosphor", String.Extra.toSentenceCase weight ]
            )


assets : Generate.Directory -> Elm.File
assets (Generate.Directory directory) =
    directory.directories
        |> Dict.toList
        |> List.concatMap
            (\( weight, Generate.Directory icons ) ->
                Dict.toList icons.files
                    |> List.map (\( filename, content ) -> ( filename, weight, content ))
            )
        |> List.sortBy (\( filename, _, _ ) -> filename)
        |> List.map
            (\( filename, weight, content ) ->
                toPathList content
                    |> Elm.withType (Annotation.list (Svg.annotation_.svg (Annotation.var "msg")))
                    |> Elm.declaration (String.Extra.camelize (String.replace ".svg" "" filename))
                    |> Elm.withDocumentation (iconLink filename weight)
                    |> Elm.expose
            )
        |> Elm.file [ "Phosphor", "Assets" ]


iconLink : String -> String -> String
iconLink filename weight =
    "![" ++ toIconName filename ++ "](https://raw.githubusercontent.com/phosphor-icons/core/main/assets/" ++ weight ++ "/" ++ filename ++ ")"


toPathList : String -> Elm.Expression
toPathList content =
    case XmlParser.parse content of
        Err _ ->
            Gen.Debug.todo "Error parsing SVG: malformed xml"

        Ok { root } ->
            case root of
                XmlParser.Element "svg" _ children ->
                    case Result.Extra.combineMap extractPath children of
                        Err e ->
                            Gen.Debug.todo ("Error parsing SVG: " ++ e)

                        Ok results ->
                            Elm.list results

                _ ->
                    Gen.Debug.todo "Wrong root node"


extractPath : XmlParser.Node -> Result String Elm.Expression
extractPath node =
    case node of
        XmlParser.Element "path" attributes [] ->
            attributes
                |> Result.Extra.combineMap
                    (\attr ->
                        case attr.name of
                            "opacity" ->
                                Ok (SvgA.opacity attr.value)

                            "d" ->
                                Ok (SvgA.d attr.value)

                            _ ->
                                Err ("Unexpected attr: " ++ attr.name)
                    )
                |> Result.map (\attrs -> Svg.path attrs [])

        _ ->
            Err "Error: wrong child node"


toIconName : String -> String
toIconName filename =
    filename
        |> String.replace "-thin.svg" ""
        |> String.replace "-light.svg" ""
        |> String.replace "-bold.svg" ""
        |> String.replace "-fill.svg" ""
        |> String.replace "-duotone.svg" ""
        |> String.replace ".svg" ""
        |> String.Extra.camelize
