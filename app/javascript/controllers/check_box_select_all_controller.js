import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox-select-parent"
export default class extends Controller {
  static targets = ["child"]
  connect() {
  }

  selectAll() {
    this.childTargets.map(x => x.checked = true)
  }

  clearAll() {
    this.childTargets.map(x => x.checked = false)
  }
}
