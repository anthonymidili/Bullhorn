import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="push-notification-status"
export default class extends Controller {
  async connect() {
    this.handleSubscriptionChange = this.checkCurrentDeviceSubscription.bind(this)
    window.addEventListener('push-subscription-changed', this.handleSubscriptionChange)
    
    await this.checkCurrentDeviceSubscription()
  }

  disconnect() {
    window.removeEventListener('push-subscription-changed', this.handleSubscriptionChange)
  }

  async checkCurrentDeviceSubscription() {
    const setupButtons = document.querySelectorAll('.setup-push-notifications-button')
    
    if (setupButtons.length === 0) return
    
    // Check if this browser/device has a push subscription
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      // Push not supported - show setup button
      this.showButtons(setupButtons)
      return
    }

    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()
      
      // Show button only if this device doesn't have a subscription
      if (!subscription || Notification.permission !== 'granted') {
        this.showButtons(setupButtons)
      } else {
        setupButtons.forEach(btn => btn.classList.add('d-none'))
      }
    } catch (error) {
      console.error('Error checking subscription:', error)
      // On error, show the button to be safe
      this.showButtons(setupButtons)
    }
  }

  showButtons(buttons) {
    buttons.forEach(btn => {
      if (btn.classList.contains('topbar-setup-push')) {
        if (!window.hasShownPushPrompt) {
          btn.classList.remove('d-none')
        }
      } else {
        btn.classList.remove('d-none')
      }
    })
    window.hasShownPushPrompt = true
  }
}
