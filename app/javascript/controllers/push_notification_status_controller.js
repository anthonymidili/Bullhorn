import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="push-notification-status"
export default class extends Controller {
  async connect() {
    await this.checkCurrentDeviceSubscription()
  }

  async checkCurrentDeviceSubscription() {
    const setupButton = document.getElementById('setup-push-notifications-button')
    
    if (!setupButton) return
    
    // Check if this browser/device has a push subscription
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      // Push not supported - show setup button
      setupButton.classList.remove('d-none')
      return
    }

    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()
      
      // Show button only if this device doesn't have a subscription
      if (!subscription || Notification.permission !== 'granted') {
        setupButton.classList.remove('d-none')
      }
    } catch (error) {
      console.error('Error checking subscription:', error)
      // On error, show the button to be safe
      setupButton.classList.remove('d-none')
    }
  }
}
