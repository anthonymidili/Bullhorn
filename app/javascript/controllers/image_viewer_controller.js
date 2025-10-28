import { Controller } from "@hotwired/stimulus";

const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

export default class extends Controller {
  static targets = ["image"];
  static values = {
    scale: { type: Number, default: 1 },
    zoomLevel: { type: Number, default: 3 },
    dragDamping: { type: Number, default: 2.0 },
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
    
    // Prevent default browser behavior on double-click
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

  // Double-click/double-tap logic
  toggleZoom() {
    if (this.scaleValue > 1) {
      this.resetZoom();
    } else {
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
      this.imageTarget.style.cursor = "grabbing";
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
    this.imageTarget.style.cursor = "grab";
  }

  // --- Touch events for dragging AND double-tap ---
  touchStart(event) {
    const currentTime = new Date().getTime();
    const tapLength = currentTime - this.lastTap;

    if (tapLength < 500 && tapLength > 0) {
      this.lastTap = 0;
      this.toggleZoom();
      event.preventDefault();
      return;
    } else {
      this.lastTap = currentTime;
    }

    if (this.scaleValue > 1 && event.touches.length === 1) {
      this.isDragging = true;
      const touch = event.touches[0];
      this.initialDragX = touch.clientX;
      this.initialDragY = touch.clientY;
      this.lastX = touch.clientX;
      this.lastY = touch.clientY;
      this.imageTarget.style.cursor = "grabbing";
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
    this.imageTarget.style.cursor = "grab";
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

    // The amount the image overflows its container at the current scale
    const overflowX = (containerRect.width * this.scaleValue - containerRect.width);
    const overflowY = (containerRect.height * this.scaleValue - containerRect.height);

    // Calculate the translation limits
    const maxX = overflowX / 2 / this.scaleValue;
    const minX = -maxX;
    const maxY = overflowY / 2 / this.scaleValue;
    const minY = -maxY;

    // Clamp the translation values
    const clampedX = clamp(this.translateX, minX, maxX);
    const clampedY = clamp(this.translateY, minY, maxY);

    this.imageTarget.style.transform = `scale(${this.scaleValue}) translate(${clampedX}px, ${clampedY}px)`;
  }

  applyTransform() {
    this.imageTarget.style.transform = `scale(${this.scaleValue}) translate(${this.translateX}px, ${this.translateY}px)`;
  }
}
