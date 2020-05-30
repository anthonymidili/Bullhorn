# Use this instead of jQuery -> with Turbo links. Turbo links will trigger the ready page:load.
document.addEventListener 'turbolinks:load', ->

  uploadWithUrl = (form, file, presignedUrl, publicUrl) ->
  # disable submit while uploading and update status
    submit = form.find("input[type='submit']").attr('disabled', true)
    $('.js-signed-upload-status').text('Uploading...')

    # create PUT request to S3
    xhr = new XMLHttpRequest()
    xhr.open 'PUT', presignedUrl
    xhr.setRequestHeader 'Content-Type', file.type

    xhr.onload = ->
      submit.removeAttr('disabled')
      if xhr.status == 200
        $('.js-signed-upload-value').val(publicUrl)
        $('.js-signed-upload-status').text('')

    xhr.onerror = ->
      submit.removeAttr('disabled')
      $('.js-signed-upload-status').text('Failed to upload. Try uploading a smaller file.')

    xhr.send file
    return

  upload = (form, file, url) ->
  # before actually uploading the file, we need to ask controller for a token
    $.ajax(
      url: url + '?filename=' + file.name + '&filetype=' + file.type,
      method: 'PUT',
      accept: 'json'
    ).success((data)->
  # pass presigned public urls to the function to actually upload it
      uploadWithUrl form, file, data.presigned_url, data.public_url
    )

  uploadHandler = (field)->
    file = field.files[0]
    if file == null
      return

    form = $(field).parents("form").eq(0)
    upload(form, file, field.dataset.presignUrl)

  $ ->
    $('.js-signed-upload').change ->
      uploadHandler(this)