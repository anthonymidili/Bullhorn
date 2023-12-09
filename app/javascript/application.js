// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/activestorage"
import "./channels"
import "./controllers"
import "trix"
import "@rails/actiontext"
import "./jquery"

import * as bootstrap from "bootstrap"

// jQuery ui setup for autocomplete.
import "./packs/jquery-ui"

// Custom JavaScripts.
import './packs/direct_uploads'

// Custom Turbo Stream Actions.
import './packs/turbo_stream_actions'

// fontawesome setup.
import '@fortawesome/fontawesome-free/js/all'
// import '@fortawesome/fontawesome-free/css/all'

// cocoon js setup.
import "cocoon-js"
