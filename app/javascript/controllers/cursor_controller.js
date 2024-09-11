import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["link"];

  connect() {
    this.defaultCursor = 'url(/assets/cursor-default.png), auto';
    this.hoverCursor = 'url(/assets/cursor-hover.png), auto';
    this.updateCursor();
  }

  updateCursor() {
    this.linkTargets.forEach(link => {
      link.addEventListener('mouseover', () => {
        document.body.style.cursor = this.hoverCursor;
      });

      link.addEventListener('mouseout', () => {
        document.body.style.cursor = this.defaultCursor;
      });
    });
  }
}
