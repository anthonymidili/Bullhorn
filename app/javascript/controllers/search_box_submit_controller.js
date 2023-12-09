import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-box-submit"
export default class extends Controller {
  connect() {
    var searchBox = $('#search_submit');
    searchBox.autocomplete({
      source: searchBox.data('autocomplete-source'),
      select: function(event, ui) {
        $(".ui-autocomplete-input").val(ui.item.value);
        searchBox.closest('form').submit();
      }
    });
  }
}
