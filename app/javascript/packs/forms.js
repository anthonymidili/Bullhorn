// Use this instead of jQuery -> with Turbo links. Turbo links will trigger the ready page:load.
document.addEventListener('turbo:load', function() {
  $(".hide_and_submit input[type='submit']").hide();
  return $('.hide_and_submit').change(function() {
    $(this).closest('form').submit();
  });
});
