document.addEventListener("turbo:load", function() {
  var searchBox = $('#search_submit');
  searchBox.autocomplete({
    source: searchBox.data('autocomplete-source'),
    select: function(event, ui) {
      $(".ui-autocomplete-input").val(ui.item.value);
      searchBox.closest('form').submit();
    }
  });
});
