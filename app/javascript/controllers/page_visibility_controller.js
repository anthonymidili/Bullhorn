import { Controller } from "@hotwired/stimulus"

// Shared state across all controller instances to prevent duplicate requests
const globalState = {
  pendingRequest: null,
  lastRequestTime: 0,
  currentStatus: 'back'
}

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
    
    // Use global state instead of instance state
    this.awayTimer = null
    this.awayDelay = 3000 // 3 second delay before marking away
    this.minRequestInterval = 1000 // Minimum 1 second between requests
    
    // Bind handlers
    this.boundHandler = this.handleVisibilityChange.bind(this)
    
    // Add event listeners
    document.addEventListener('visibilitychange', this.boundHandler)
    window.addEventListener('blur', () => this.handleBlur())
    window.addEventListener('focus', () => this.handleFocus())
  }

  disconnect() {
    // Clear any pending timer
    if (this.awayTimer) {
      clearTimeout(this.awayTimer)
      this.awayTimer = null
    }
    
    if (this.boundHandler) {
      document.removeEventListener('visibilitychange', this.boundHandler)
    }
  }

  handleBlur() {
    this.scheduleMarkAway()
  }

  handleFocus() {
    this.cancelMarkAway()
    this.markBack()
  }

  handleVisibilityChange() {
    if (document.hidden) {
      this.scheduleMarkAway()
    } else {
      this.cancelMarkAway()
      this.markBack()
    }
  }

  scheduleMarkAway() {
    // If already away or timer is already running, don't schedule again
    if (globalState.currentStatus === 'away' || this.awayTimer) return
    
    // Schedule marking away after delay
    this.awayTimer = setTimeout(() => {
      this.markAway()
      this.awayTimer = null
    }, this.awayDelay)
  }

  cancelMarkAway() {
    // Cancel pending away timer if user comes back quickly
    if (this.awayTimer) {
      clearTimeout(this.awayTimer)
      this.awayTimer = null
    }
  }

  markAway() {
    // Only send if status is changing
    if (globalState.currentStatus === 'away') return
    
    globalState.currentStatus = 'away'
    this.sendStatusUpdate('mark_away')
  }

  markBack() {
    // Only send if status is changing
    if (globalState.currentStatus === 'back') return
    
    globalState.currentStatus = 'back'
    this.sendStatusUpdate('mark_back')
  }

  async sendStatusUpdate(action) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (!csrfToken) return
    
    // Prevent duplicate requests using global state
    const now = Date.now()
    if (globalState.pendingRequest || (now - globalState.lastRequestTime < this.minRequestInterval)) {
      return
    }
    
    // Mark request as pending
    globalState.pendingRequest = action
    
    try {
      await fetch(`/users/${this.userIdValue}/${action}`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Content-Type': 'application/json'
        }
      })
      globalState.lastRequestTime = Date.now()
    } catch (error) {
      console.error(`Status update failed: ${error}`)
    } finally {
      globalState.pendingRequest = null
    }
  }
}
