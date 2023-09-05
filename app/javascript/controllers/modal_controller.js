import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    close: Boolean
  }

  connect() {
    this.modal = new bootstrap.Modal(this.element, {
      keyboard: false
    })
    this.modal.show()
  }

  disconnect() {
    this.modal.hide()
  }

  closeValueChanged() {
    if (this.closeValue) {
      this.closeModal();
    }
  }

  closeModal() {
    let modalElement = this.element.querySelector('.modal');
    let modalInstance = bootstrap.Modal.getInstance(modalElement);

    if (!modalInstance) {
      modalInstance = new bootstrap.Modal(modalElement);
    }

    modalInstance.hide();
  }
}
