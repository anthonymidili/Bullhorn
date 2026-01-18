import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="page-visibility"
// Manages user online status based on page visibility
export default class extends Controller {
  static values = {
    userId: String  // Tells Stimulus to look for data-page-visibility-user-id-value
  }
  
  connect() {
    // Only run if user is logged in and userId is available
    const csrfToken = document.querySelector('meta[name="csrf-token"]')
    if (!csrfToken || !this.userIdValue) return
    
    // Bind handlers
    this.boundHandler = this.handleVisibilityChange.bind(this)
    
    // Add event listeners
    document.addEventListener('visibilitychange', this.boundHandler)
    window.addEventListener('blur', () => this.handleBlur())
    window.addEventListener('focus', () => this.handleFocus())
  }

  disconnect() {
    if (this.boundHandler) {
      document.removeEventListener('visibilitychange', this.boundHandler)
    }
  }

  handleBlur() {
    this.markAway()
  }

  handleFocus() {
    this.markBack()
  }

  handleVisibilityChange() {
    if (document.hidden) {
      this.markAway()
    } else {
      this.markBack()
    }
  }

  markAway() {
    this.sendStatusUpdate('mark_away')
  }

  markBack() {
    this.sendStatusUpdate('mark_back')
  }

  async sendStatusUpdate(action) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (!csrfToken) return
    
    try {
      await fetch(`/users/${this.userIdValue}/${action}`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Content-Type': 'application/json'
        }
      })
    } catch (error) {
      console.error(`Status update failed: ${error}`)
    }
  }
}
