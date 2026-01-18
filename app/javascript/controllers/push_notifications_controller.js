import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="push-notifications"
export default class extends Controller {
  static targets = ["enableButton", "disableButton"]

  async connect() {
    this.permission = Notification.permission
    await this.checkSubscriptionStatus()
    this.updateButtons()
  }

  // Convert base64 string to Uint8Array for VAPID key
  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/\-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  async enable() {
    if (!('Notification' in window)) {
      alert('This browser does not support notifications')
      return
    }

    const permission = await Notification.requestPermission()
    this.permission = permission
    
    if (permission === 'granted') {
      await this.subscribe()
    } else if (permission === 'denied') {
      alert('Push notification permission denied. Please enable notifications in your browser settings.')
    }
    
    this.updateButtons()
  }

  async disable() {
    const confirmed = confirm('Are you sure you want to disable push notifications?')
    if (confirmed) {
      const success = await this.unsubscribe()
      if (success) {
        // Force permission check after unsubscribing
        await this.checkSubscriptionStatus()
        this.updateButtons()
      } else {
        alert('Failed to disable push notifications. Please try again.')
      }
    }
  }

  async subscribe() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      console.warn('Push notifications are not supported')
      return false
    }

    try {
      const registration = await navigator.serviceWorker.ready
      
      // Get VAPID public key from server
      const response = await fetch('/push_subscriptions/vapid_public_key')
      const data = await response.json()
      const vapidPublicKey = data.public_key
      
      if (!vapidPublicKey) {
        console.error('VAPID public key not configured')
        return false
      }

      // Subscribe to push notifications
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(vapidPublicKey)
      })

      // Send subscription to server
      const subscriptionData = {
        endpoint: subscription.endpoint,
        keys: {
          p256dh: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey('p256dh')))),
          auth: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey('auth'))))
        }
      }

      const saveResponse = await fetch('/push_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ subscription: subscriptionData })
      })

      const result = await saveResponse.json()
      
      if (result.success) {
        console.log('Successfully subscribed to push notifications')
        this.permission = 'granted'
        this.updateButtons()
        return true
      } else {
        console.error('Failed to save subscription:', result.errors)
        return false
      }
    } catch (error) {
      console.error('Error subscribing to push notifications:', error)
      return false
    }
  }

  async unsubscribe() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      return false
    }

    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()
      
      if (subscription) {
        // Remove subscription from server
        const response = await fetch('/push_subscriptions', {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({ endpoint: subscription.endpoint })
        })
        
        // Unsubscribe from push service
        const unsubscribed = await subscription.unsubscribe()
        
        if (unsubscribed) {
          console.log('Successfully unsubscribed from push notifications')
          return true
        } else {
          console.error('Failed to unsubscribe from push service')
          return false
        }
      } else {
        // No subscription exists
        console.log('No subscription to remove')
        return true
      }
    } catch (error) {
      console.error('Error unsubscribing from push notifications:', error)
      return false
    }
  }

  async checkSubscriptionStatus() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      this.permission = Notification.permission
      return
    }

    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()
      
      // Only mark as granted if both permission is granted AND subscription exists
      if (subscription && Notification.permission === 'granted') {
        this.permission = 'granted'
      } else if (Notification.permission === 'denied') {
        this.permission = 'denied'
      } else {
        // Permission is granted or default, but no subscription exists
        this.permission = 'default'
      }
    } catch (error) {
      console.error('Error checking subscription status:', error)
      this.permission = 'default'
    }
  }

  updateButtons() {
    if (!this.hasEnableButtonTarget || !this.hasDisableButtonTarget) return
    
    if (this.permission === 'granted') {
      // Hide enable button, show disable button
      this.enableButtonTarget.classList.add('d-none')
      this.disableButtonTarget.classList.remove('d-none')
    } else if (this.permission === 'denied') {
      // Show blocked state on enable button, hide disable button
      this.enableButtonTarget.innerHTML = '<i class="fa-solid fa-bell-slash"></i> Push Notifications Blocked'
      this.enableButtonTarget.classList.remove('btn-primary', 'btn-success', 'd-none')
      this.enableButtonTarget.classList.add('btn-danger')
      this.enableButtonTarget.disabled = true
      this.disableButtonTarget.classList.add('d-none')
    } else {
      // Show enable button, hide disable button
      this.enableButtonTarget.innerHTML = '<i class="fa-solid fa-bell"></i> Enable Push Notifications'
      this.enableButtonTarget.classList.add('btn-primary')
      this.enableButtonTarget.classList.remove('btn-success', 'btn-danger', 'd-none')
      this.enableButtonTarget.disabled = false
      this.disableButtonTarget.classList.add('d-none')
    }
  }
}
