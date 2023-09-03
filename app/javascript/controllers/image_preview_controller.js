import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview"];

  preview() {
    let input = this.inputTarget;
    let preview = this.previewTarget;

    if (input.files && input.files[0]) {
      let reader = new FileReader();
      reader.onload = function(e) {
        preview.src = e.target.result;
      };
      reader.readAsDataURL(input.files[0]);
    }
  }
}
