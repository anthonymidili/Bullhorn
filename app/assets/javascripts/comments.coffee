jQuery.fn.showFormOnClick = ->
  @find('.showHiddenForm').on 'click', ->
    $(this).closest("li[id^='comment_']").find('form.hidden').toggle()

# Use this instead of jQuery -> with Turbo links. Turbo links will trigger the ready page:load.
document.addEventListener 'turbolinks:load', ->
  $("li[id^='comment_']").showFormOnClick()
