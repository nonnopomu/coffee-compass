import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image", "placeholder", "filename"]

  show() {
    const file = this.inputTarget.files[0]

    if (!file) return

    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = file.name
    }

    if (!file.type.startsWith("image/")) return

    const reader = new FileReader()

    reader.onload = () => {
      this.imageTarget.src = reader.result
      this.imageTarget.classList.remove("hidden")
      this.placeholderTarget.classList.add("hidden")
    }

    reader.readAsDataURL(file)
  }
}
