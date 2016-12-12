# Use this instead of jQuery -> with Turbo links. Turbo links will trigger the ready page:load.
document.addEventListener 'turbolinks:load', ->
  micropostField = $('#micropost_content')
  maxCharacters = micropostField.data('maximum-characters')
  countdown = $('.countdown')

  updateCountdown = ->
    remaining = maxCharacters - (micropostField.val().length)
    # display amount of characters remaining.
    countdown.text remaining + ' characters remaining'
    # Change .countdown font color when close to the end of characters remaining.
    if remaining < 21
      countdown.addClass('close_to_end')
    else
      countdown.removeClass('close_to_end')
    return

  # Initiate updateCountdown on page load.
  if micropostField.length
    updateCountdown()

  # Update the counter when micropostField changes.
  micropostField.on 'change keyup', ->
    updateCountdown()
    return
