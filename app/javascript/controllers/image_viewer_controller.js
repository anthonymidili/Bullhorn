// app/javascript/controllers/image_viewer_controller.js
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

    const dx = event.clientX - this.lastX;
    const dy = event.clientY - this.lastY;

    this.translateX += dx;
    this.translateY += dy;

    this.lastX = event.clientX;
    this.lastY = event.clientY;

    this.applyTransform();
  }

  mouseUp() {
    this.isDragging = false;
    this.imageTarget.style.cursor = "grab";
  }

  // --- Utility method ---

  applyTransform() {
    this.imageTarget.style.transform = `scale(${this.scaleValue}) translate(${this.translateX}px, ${this.translateY}px)`;
  }
}
