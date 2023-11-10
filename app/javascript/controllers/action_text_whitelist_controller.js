import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="action_text_whitelist"
export default class extends Controller {
  connect() {
    const allowedTypes = ["image/png", "image/jpg", "image/jpeg", "image/gif", 
    "image/tiff", "image/bmp", "video/mp4", "video/mpeg", "video/mpg", "video/mov", 
    "video/avi", "video/wmv", "video/m4v", "video/flv", "video/webm", "video/mkv", 
    "video/m2v", "audio/mp3", "audio/ogg", "audio/m4a", "audio/wma", "audio/wav", 
    "audio/aac", "audio/flac", "audio/aiff", "audio/aif", "audio/mpeg"]

    document.addEventListener("trix-file-accept", e => {
      if (!allowedTypes.includes(e.file.type)) {
        e.preventDefault()
        alert("This filetype is not supported.")
      }
    })
  }
}
