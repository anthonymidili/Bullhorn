import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosubmit-form"
export default class extends Controller {
  // static targets = [ "submitBtn" ]
  
  connect() {
    var form = this.element
    var formSubmitBtn = form.querySelector("input[type=submit]")
    formSubmitBtn.style.display = 'none'
  }

  submitChange(event) {
    event.preventDefault()
    event.target.form.requestSubmit()
  }
}
