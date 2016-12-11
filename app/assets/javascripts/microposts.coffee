jQuery ->
  micropostField = $('#micropost_content')
  maximumCharacters = micropostField.data('maximum-characters')

  updateCountdown = ->
    remaining = maximumCharacters - (micropostField.val().length)
    $('.countdown').text remaining + ' characters remaining'
    return

  updateCountdown()

  micropostField.on 'change keyup', ->
    updateCountdown()
    return

