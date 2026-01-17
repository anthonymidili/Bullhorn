// Register service worker for PWA functionality
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker
      .register('/service-worker.js')
      .then((registration) => {
        console.log('ServiceWorker registration successful with scope: ', registration.scope);
      })
      .catch((error) => {
        console.log('ServiceWorker registration failed: ', error);
      });
  });
}

// Monitor online/offline status
window.addEventListener('online', () => {
  hideOfflineNotification();
});

window.addEventListener('offline', () => {
  showOfflineNotification();
});

// Check initial connection status
if (!navigator.onLine) {
  showOfflineNotification();
}

function showOfflineNotification() {
  // Check if notification already exists
  if (document.getElementById('offline-notification')) {
    return;
  }

  const notification = document.createElement('div');
  notification.id = 'offline-notification';
  notification.className = 'alert alert-warning alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3';
  notification.style.cssText = 'z-index: 9999; max-width: 500px;';
  notification.innerHTML = `
    <i class="bi bi-wifi-off me-2"></i>
    <strong>You're offline</strong> - Some features may be limited.
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  `;
  
  document.body.appendChild(notification);
}

function hideOfflineNotification() {
  const notification = document.getElementById('offline-notification');
  if (notification) {
    notification.remove();
  }
}

// Listen for app install prompt
let deferredPrompt;
const installButton = document.getElementById('pwa-install-button');

// Detect iOS
function isIOS() {
  return [
    'iPad Simulator',
    'iPhone Simulator',
    'iPod Simulator',
    'iPad',
    'iPhone',
    'iPod'
  ].includes(navigator.platform)
  // iPad on iOS 13 detection
  || (navigator.userAgent.includes("Mac") && "ontouchend" in document);
}

// Detect if app is already installed (running in standalone mode)
function isInstalled() {
  return window.matchMedia('(display-mode: standalone)').matches 
    || window.navigator.standalone 
    || document.referrer.includes('android-app://');
}

// Show install button on iOS if not already installed
if (installButton && isIOS() && !isInstalled()) {
  installButton.style.display = 'block';
}

window.addEventListener('beforeinstallprompt', (e) => {
  // Prevent the mini-infobar from appearing on mobile
  e.preventDefault();
  // Stash the event so it can be triggered later
  deferredPrompt = e;
  
  // Show the install button (for non-iOS browsers)
  if (installButton) {
    installButton.style.display = 'block';
  }
});

// Handle install button click
if (installButton) {
  installButton.addEventListener('click', async (e) => {
    e.preventDefault();
    
    // iOS users - show instructions
    if (isIOS()) {
      alert('To install BullhornXL:\n\n1. Tap the Share button (square with arrow)\n2. Scroll down and tap "Add to Home Screen"\n3. Tap "Add" in the top right');
      return;
    }
    
    // Chrome/Edge/other browsers
    if (!deferredPrompt) {
      return;
    }
    
    // Show the install prompt
    deferredPrompt.prompt();
    
    // Wait for the user to respond to the prompt
    const { outcome } = await deferredPrompt.userChoice;
    console.log(`User response to the install prompt: ${outcome}`);
    
    // Clear the deferredPrompt for next time
    deferredPrompt = null;
    
    // Hide the install button
    installButton.style.display = 'none';
  });
}

// Track when app is installed
window.addEventListener('appinstalled', () => {
  console.log('BullhornXL PWA was installed');
  deferredPrompt = null;
  
  // Hide the install button
  if (installButton) {
    installButton.style.display = 'none';
  }
});
