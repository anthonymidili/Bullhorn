jQuery.fn.showFormOnClick = ->
  @find('.showHiddenForm').on 'click', ->
    $(this).closest('.findHiddenForm')
      .find('.hiddenForm').toggle()
      .find('textarea.comment_content').val('')
  this

# Use this instead of jQuery -> with Turbo links. Turbo links will trigger the ready page:load.
document.addEventListener 'turbolinks:load', ->
  $('.comments_box').showFormOnClick()
