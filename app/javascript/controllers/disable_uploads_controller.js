import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="disable-uploads"
export default class extends Controller {
  connect() {
    // Disable trix uploads: https://github.com/basecamp/trix/issues/604#issuecomment-600974875
    // Get rid of the upload button
    document.addEventListener("trix-initialize", function(e) {
      const fileTools = document.querySelector(".trix-button-group--file-tools");
      // null check hack: trix-initialize gets called twice for some reason, sometimes it is null :shrug:
      fileTools?.remove();
    });
    // Dont allow images/etc to be pasted
    document.addEventListener("trix-attachment-add", function(event) {
      if (!event.attachment.file) {
        event.attachment.remove()
      }
    })
    // No files, ever
    document.addEventListener("trix-file-accept", function(event) {
      event.preventDefault();
    });
  };
};
