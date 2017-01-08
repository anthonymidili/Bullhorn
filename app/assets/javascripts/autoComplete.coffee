# Use this instead of jQuery -> with Turbo links. Turbo links will trigger the ready page:load.
document.addEventListener 'turbolinks:load', ->

  textBox = $('.autocomplete_text_box')
  arraySource = textBox.data('autocomplete-source')

  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    split(term).pop()

  textBox.on('keydown', (event) ->
    if event.keyCode == $.ui.keyCode.TAB and $(this).autocomplete('instance').menu.active
      event.preventDefault()
    return
  ).autocomplete
    minLength: 0
    source: (request, response) ->
# delegate back to autocomplete, but extract the last term
      response $.ui.autocomplete.filter(arraySource, extractLast(request.term))
      return
    focus: ->
# prevent value inserted on focus
      false
    select: (event, ui) ->
      terms = split(@value)
      # remove the current input
      terms.pop()
      # add the selected item
      terms.push ui.item.value
      # add placeholder to get the comma-and-space at the end
      terms.push ''
      @value = terms.join(', ')
      false
  return
