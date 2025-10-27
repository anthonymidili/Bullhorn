import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["image"];
  static values = {
    scale: { type: Number, default: 1 },
    zoomLevel: { type: Number, default: 2 },
  };

  initialize() {
    this.isDragging = false;
    this.lastX = 0;
    this.lastY = 0;
    this.translateX = 0;
    this.translateY = 0;

    // Prevent default browser behavior like context menu on dblclick
    this.imageTarget.addEventListener('dblclick', (e) => {
      e.preventDefault();
    });
    // Prevent default browser behavior like scrolling while dragging on touch devices
    this.imageTarget.addEventListener('touchstart', (e) => {
      if (this.scaleValue > 1) {
        e.preventDefault();
      }
    }, { passive: false });
  }

  // Called on double-click to toggle zoom
  toggleZoom() {
    if (this.scaleValue > 1) {
      this.resetZoom();
    } else {
      this.scaleValue = this.zoomLevelValue;
      this.applyTransform();
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
      this.lastX = event.clientX;
      this.lastY = event.clientY;
      this.imageTarget.style.cursor = "grabbing";
    }
  }

  mouseMove(event) {
    if (!this.isDragging || this.scaleValue <= 1) return;

    this.updatePosition(event.clientX, event.clientY);
  }

  mouseUp() {
    this.isDragging = false;
    this.imageTarget.style.cursor = "grab";
  }

  // --- Touch events for dragging ---

  touchStart(event) {
    if (this.scaleValue > 1) {
      this.isDragging = true;
      // Get coordinates from the first touch point
      this.lastX = event.touches[0].clientX;
      this.lastY = event.touches[0].clientY;
      this.imageTarget.style.cursor = "grabbing";
    }
  }

  touchMove(event) {
    if (!this.isDragging || this.scaleValue <= 1) return;

    // Stop the browser's native touch behavior
    event.preventDefault();

    // Update position using coordinates from the first touch point
    this.updatePosition(event.touches[0].clientX, event.touches[0].clientY);
  }

  touchEnd() {
    this.isDragging = false;
    this.imageTarget.style.cursor = "grab";
  }

  // --- Utility methods ---

  updatePosition(currentX, currentY) {
    const dx = currentX - this.lastX;
    const dy = currentY - this.lastY;

    // Apply translations relative to the current scale
    this.translateX += dx / this.scaleValue;
    this.translateY += dy / this.scaleValue;

    this.lastX = currentX;
    this.lastY = currentY;

    this.applyTransform();
  }

  applyTransform() {
    this.imageTarget.style.transform = `scale(${this.scaleValue}) translate(${this.translateX}px, ${this.translateY}px)`;
  }
}
