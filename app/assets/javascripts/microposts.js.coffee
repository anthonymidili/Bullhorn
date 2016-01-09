updateCountdown = ->
  # 150 is the max message length
  remaining = 150 - (jQuery('#micropost_content').val().length)
  jQuery('.countdown').text remaining + ' characters remaining'
  return

jQuery(document).ready ($) ->
  updateCountdown()
  $('#micropost_content').change updateCountdown
  $('#micropost_content').keyup updateCountdown
  return
