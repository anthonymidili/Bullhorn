// Push Notifications Management
let pushNotificationPermission = Notification.permission;

// Convert base64 string to Uint8Array for VAPID key
function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding)
    .replace(/\-/g, '+')
    .replace(/_/g, '/');

  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

// Subscribe to push notifications
async function subscribeToPushNotifications() {
  if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
    console.warn('Push notifications are not supported');
    return false;
  }

  try {
    // Get service worker registration
    const registration = await navigator.serviceWorker.ready;
    
    // Get VAPID public key from server
    const response = await fetch('/push_subscriptions/vapid_public_key');
    const data = await response.json();
    const vapidPublicKey = data.public_key;
    
    if (!vapidPublicKey) {
      console.error('VAPID public key not configured');
      return false;
    }

    // Subscribe to push notifications
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(vapidPublicKey)
    });

    // Send subscription to server
    const subscriptionData = {
      endpoint: subscription.endpoint,
      keys: {
        p256dh: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey('p256dh')))),
        auth: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey('auth'))))
      }
    };

    const saveResponse = await fetch('/push_subscriptions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ subscription: subscriptionData })
    });

    const result = await saveResponse.json();
    
    if (result.success) {
      console.log('Successfully subscribed to push notifications');
      pushNotificationPermission = 'granted';
      updateNotificationButton();
      return true;
    } else {
      console.error('Failed to save subscription:', result.errors);
      return false;
    }
  } catch (error) {
    console.error('Error subscribing to push notifications:', error);
    return false;
  }
}

// Unsubscribe from push notifications
async function unsubscribeFromPushNotifications() {
  if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
    return false;
  }

  try {
    const registration = await navigator.serviceWorker.ready;
    const subscription = await registration.pushManager.getSubscription();
    
    if (subscription) {
      // Remove subscription from server
      await fetch('/push_subscriptions', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ endpoint: subscription.endpoint })
      });
      
      // Unsubscribe from push service
      await subscription.unsubscribe();
      console.log('Successfully unsubscribed from push notifications');
      updateNotificationButton();
      return true;
    }
  } catch (error) {
    console.error('Error unsubscribing from push notifications:', error);
    return false;
  }
}

// Request notification permission and subscribe
async function requestNotificationPermission() {
  if (!('Notification' in window)) {
    alert('This browser does not support notifications');
    return;
  }

  const permission = await Notification.requestPermission();
  pushNotificationPermission = permission;
  
  if (permission === 'granted') {
    await subscribeToPushNotifications();
  } else if (permission === 'denied') {
    alert('Push notification permission denied. Please enable notifications in your browser settings.');
  }
  
  updateNotificationButton();
}

// Update notification button UI
function updateNotificationButton() {
  const notificationButton = document.getElementById('notification-permission-button');
  
  if (!notificationButton) return;
  
  if (pushNotificationPermission === 'granted') {
    notificationButton.innerHTML = '<i class="fa-solid fa-bell"></i> Push Notifications Enabled';
    notificationButton.classList.remove('btn-primary');
    notificationButton.classList.add('btn-success');
    notificationButton.disabled = false;
  } else if (pushNotificationPermission === 'denied') {
    notificationButton.innerHTML = '<i class="fa-solid fa-bell-slash"></i> Push Notifications Blocked';
    notificationButton.classList.remove('btn-primary', 'btn-success');
    notificationButton.classList.add('btn-danger');
    notificationButton.disabled = true;
  } else {
    notificationButton.innerHTML = '<i class="fa-solid fa-bell"></i> Enable Push Notifications';
    notificationButton.classList.add('btn-primary');
    notificationButton.classList.remove('btn-success', 'btn-danger');
    notificationButton.disabled = false;
  }
}

// Check current subscription status
async function checkSubscriptionStatus() {
  if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
    pushNotificationPermission = Notification.permission;
    updateNotificationButton();
    return;
  }

  try {
    const registration = await navigator.serviceWorker.ready;
    const subscription = await registration.pushManager.getSubscription();
    
    // Only mark as granted if both permission is granted AND subscription exists
    if (subscription && Notification.permission === 'granted') {
      pushNotificationPermission = 'granted';
    } else {
      pushNotificationPermission = Notification.permission;
    }
    
    updateNotificationButton();
  } catch (error) {
    console.error('Error checking subscription status:', error);
    pushNotificationPermission = Notification.permission;
    updateNotificationButton();
  }
}

// Initialize notification button when page loads
document.addEventListener('turbo:load', async () => {
  const notificationButton = document.getElementById('notification-permission-button');
  
  if (notificationButton) {
    // Check current subscription status first
    await checkSubscriptionStatus();
    
    // Add click event listener
    notificationButton.addEventListener('click', requestNotificationPermission);
  }
});
