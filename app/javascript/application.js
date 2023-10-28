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
import './packs/autocomplete'
import './packs/autocompleteSubmit'
import './packs/direct_uploads'

// fontawesome setup.
import '@fortawesome/fontawesome-free/js/all'
// import '@fortawesome/fontawesome-free/css/all'

// cocoon js setup.
import "cocoon-js"
