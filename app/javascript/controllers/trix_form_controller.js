import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trix-form"
export default class extends Controller {
  static targets = ['submit']

  checkType(event) {
    const allowedTypes = ["image/png", "image/jpg", "image/jpeg", "image/gif", 
    "image/tiff", "image/bmp", "video/mp4", "video/mpeg", "video/mpg", "video/mov", 
    "video/avi", "video/wmv", "video/m4v", "video/flv", "video/webm", "video/mkv", 
    "video/m2v", "audio/mp3", "audio/ogg", "audio/m4a", "audio/wma", "audio/wav", 
    "audio/aac", "audio/flac", "audio/aiff", "audio/aif", "audio/mpeg"]

    if (!allowedTypes.includes(event.file.type)) {
      event.preventDefault()
      alert("This filetype is not supported.")
    }
  }

  disableSubmit(/*event*/) {
    const { hasTrixAttachmentsUploading } = this
    this.submitTargets.forEach(submitTarget => submitTarget.disabled = hasTrixAttachmentsUploading)
  }

  get hasTrixAttachmentsUploading() {
    return this.trixAttachments.some(attachment => attachment.isPending())
  }

  get trixAttachments() {
    return this.trixElements.flatMap(trix => trix.editor.getDocument().getAttachments())
  }

  get trixElements() {
    return Array.from(this.element.querySelectorAll("trix-editor"))
  }
}
