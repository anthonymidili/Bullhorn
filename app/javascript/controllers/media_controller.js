import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="media"
export default class extends Controller {
  static targets = ["player"]

  // This action is triggered when a media player starts playing
  play(event) {
    // Get the player that was just activated
    const currentPlayer = event.currentTarget;

    // Loop through all other players and pause them
    this.playerTargets.forEach(otherPlayer => {
      if (otherPlayer !== currentPlayer) {
        otherPlayer.pause();
      }
    });
  }
}
