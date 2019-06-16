// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// TODO: bootstrap.js currently relies on popper.js, but we don't use popper tooltips bc
// I don't trust them to play nice with LiveView. Don't ship all this dead code.
import "bootstrap"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import "./utilities"
