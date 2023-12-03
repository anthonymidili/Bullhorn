import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-box"
export default class extends Controller {
  connect() {
    var searchBox = $('#search');
    searchBox.autocomplete({
      source: searchBox.data('autocomplete-source')
    });
  }
}
