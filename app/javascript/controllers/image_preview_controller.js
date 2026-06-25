import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image", "placeholder", "removeField", "removeButton"]

  show() {
    const file = this.inputTarget.files[0]

    if (!file || !file.type.startsWith("image/")) return

    const reader = new FileReader()

    reader.onload = () => {
      if (this.hasRemoveFieldTarget) this.removeFieldTarget.value = "0"

      this.imageTarget.src = reader.result
      this.imageTarget.classList.remove("hidden")
      this.placeholderTarget.classList.add("hidden")

      if (this.hasRemoveButtonTarget) this.removeButtonTarget.classList.remove("hidden")
    }

    reader.readAsDataURL(file)
  }

  remove(event) {
    event.preventDefault()

    this.inputTarget.value = ""

    if (this.hasRemoveFieldTarget) this.removeFieldTarget.value = "1"

    this.imageTarget.removeAttribute("src")
    this.imageTarget.classList.add("hidden")
    this.placeholderTarget.classList.remove("hidden")
    this.placeholderTarget.classList.add("flex")

    if (this.hasRemoveButtonTarget) this.removeButtonTarget.classList.add("hidden")
  }
}
