function updateCountdown() {
// 500 is the max message length
var remaining = 500 - jQuery('#micropost_content').val().length;
jQuery('.countdown').text(remaining + ' characters remaining');
}

jQuery(document).ready(function($) {
updateCountdown();
  $('#micropost_content').change(updateCountdown);
  $('#micropost_content').keyup(updateCountdown);
});