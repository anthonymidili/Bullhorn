import { Controller } from "@hotwired/stimulus";

const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

export default class extends Controller {
  static targets = ["image"];
  static values = {
    scale: { type: Number, default: 1 },
    zoomLevel: { type: Number, default: 3 },
    dragDamping: { type: Number, default: 1.5 },
    dragThreshold: { type: Number, default: 2 },
  };

  initialize() {
    this.isDragging = false;
    this.lastX = 0;
    this.lastY = 0;
    this.translateX = 0;
    this.translateY = 0;
    this.lastTap = 0;
    this.dragStarted = false;
    this.initialDragX = 0;
    this.initialDragY = 0;
    
    // Prevent default browser behavior like scrolling while dragging on touch devices
    this.imageTarget.addEventListener('touchstart', (e) => {
      // Prevent default scrolling only if we are using a single finger to interact
      if (e.touches.length === 1) {
        e.preventDefault();
      }
    }, { passive: false });
  }

  // Double-click/double-tap logic
  toggleZoom(event) {
    if (this.scaleValue > 1) {
      this.resetZoom();
    } else {
      // Logic to center zoom on the interaction point (mouse/touch coordinates)
      const rect = this.element.getBoundingClientRect();
      const clientX = event.clientX || event.touches[0].clientX;
      const clientY = event.clientY || event.touches[0].clientY;

      const clickX = clientX - rect.left;
      const clickY = clientY - rect.top;

      // Calculate new translation values to center zoom on click point
      this.translateX = (rect.width / 2 - clickX) / this.zoomLevelValue;
      this.translateY = (rect.height / 2 - clickY) / this.zoomLevelValue;

      this.scaleValue = this.zoomLevelValue;
      this.applyConstrainedTransform();
    }
  }

  // Resets the image to its original state
  resetZoom() {
    this.scaleValue = 1;
    this.translateX = 0;
    this.translateY = 0;
    this.applyTransform();
  }

  // --- Mouse events for dragging ---
  mouseDown(event) {
    if (this.scaleValue > 1) {
      this.isDragging = true;
      this.initialDragX = event.clientX;
      this.initialDragY = event.clientY;
      this.lastX = event.clientX;
      this.lastY = event.clientY;
      this.element.classList.add('grabbing'); // Add CSS class
    }
  }

  mouseMove(event) {
    if (!this.isDragging || this.scaleValue <= 1) return;

    if (!this.dragStarted) {
      const distance = Math.sqrt(
        (event.clientX - this.initialDragX) ** 2 +
        (event.clientY - this.initialDragY) ** 2
      );
      if (distance > this.dragThresholdValue) {
        this.dragStarted = true;
      } else {
        return;
      }
    }

    this.updatePosition(event.clientX, event.clientY);
  }

  mouseUp() {
    this.isDragging = false;
    this.dragStarted = false;
    this.element.classList.remove('grab'); // Remove CSS class
  }

  // --- Touch events for dragging AND double-tap ---
  touchStart(event) {
    if (event.touches.length === 1) {
      const currentTime = new Date().getTime();
      const tapLength = currentTime - this.lastTap;

      if (tapLength < 500 && tapLength > 0) {
        this.lastTap = 0;
        // Pass event to toggleZoom for centering logic
        this.toggleZoom(event);
        // event.preventDefault() is handled by the initialize listener
        return;
      } else {
        this.lastTap = currentTime;
      }

      if (this.scaleValue > 1) {
        this.isDragging = true;
        const touch = event.touches[0];
        this.initialDragX = touch.clientX;
        this.initialDragY = touch.clientY;
        this.lastX = touch.clientX;
        this.lastY = touch.clientY;
        this.element.classList.add('grabbing');
      }
    }
  }

  touchMove(event) {
    if (!this.isDragging || this.scaleValue <= 1 || event.touches.length !== 1) return;
    
    if (!this.dragStarted) {
      const touch = event.touches[0];
      const distance = Math.sqrt(
        (touch.clientX - this.initialDragX) ** 2 +
        (touch.clientY - this.initialDragY) ** 2
      );
      if (distance > this.dragThresholdValue) {
        this.dragStarted = true;
      } else {
        return;
      }
    }

    const touch = event.touches[0];
    this.updatePosition(touch.clientX, touch.clientY);
  }

  touchEnd() {
    this.isDragging = false;
    this.dragStarted = false;
    this.element.classList.remove('grab');
  }
  
  touchCancel() {
    this.touchEnd();
  }

  // --- Utility methods ---
  updatePosition(currentX, currentY) {
    const dx = currentX - this.lastX;
    const dy = currentY - this.lastY;

    // Apply drag damping factor
    this.translateX += (dx / this.scaleValue) * this.dragDampingValue;
    this.translateY += (dy / this.scaleValue) * this.dragDampingValue;

    this.lastX = currentX;
    this.lastY = currentY;

    this.applyConstrainedTransform();
  }

  applyConstrainedTransform() {
    const container = this.element;
    const containerRect = container.getBoundingClientRect();
    const imageRect = this.imageTarget.getBoundingClientRect();

    // Max movement is half the difference between image width and container width
    const maxX = (imageRect.width - containerRect.width) / 2 / this.scaleValue;
    const maxY = (imageRect.height - containerRect.height) / 2 / this.scaleValue;
    
    // Clamp the translation values
    const clampedX = clamp(this.translateX, -maxX, maxX);
    const clampedY = clamp(this.translateY, -maxY, maxY);

    // Update internal tracking variables to the clamped values
    this.translateX = clampedX;
    this.translateY = clampedY;

    this.applyTransform();
  }

  applyTransform() {
    this.imageTarget.style.transform = `scale(${this.scaleValue}) translate(${this.translateX}px, ${this.translateY}px)`;
  }
}
