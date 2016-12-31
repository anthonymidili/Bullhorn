jQuery.fn.showFormOnClick = ->
  @find('.showHiddenForm').on 'click', ->
    $(this).closest('.findHiddenForm').find('.hiddenForm').toggle()
  this

jQuery ->
  $('.comments_box').showFormOnClick()
