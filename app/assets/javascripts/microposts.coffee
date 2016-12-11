jQuery ->
  updateCountdown = ->
    # 150 is the max message length
    remaining = 150 - ($('#micropost_content').val().length)
    $('.countdown').text remaining + ' characters remaining'
    return

  updateCountdown()

  $('#micropost_content').on 'change keyup', ->
    updateCountdown()
    return

