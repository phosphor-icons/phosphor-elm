#!/usr/bin/env node
const path = require("path");

const ASSETS_PATH = path.join(__dirname, "../core/assets");
const COMPONENTS_PATH = path.join(__dirname, "../src/Test.elm");
const INDEX_PATH = path.join(__dirname, "../src/Phosphor.elm");
const TEST_PATH = path.join(__dirname, "../example/src/Test.elm");

module.exports = { ASSETS_PATH, COMPONENTS_PATH, INDEX_PATH, TEST_PATH };
