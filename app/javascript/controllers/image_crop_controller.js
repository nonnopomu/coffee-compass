import { Controller } from "@hotwired/stimulus"

const MIME_TYPE = "image/jpeg"
const FILE_EXTENSION = "jpg"

export default class extends Controller {
  static targets = [
    "input",
    "image",
    "placeholder",
    "removeField",
    "removeButton",
    "modal",
    "frame",
    "sourceImage",
    "cropBox",
    "applyButton",
    "error"
  ]

  static values = {
    outputWidth: { type: Number, default: 1280 },
    outputHeight: { type: Number, default: 720 },
    quality: { type: Number, default: 0.82 },
    fileName: { type: String, default: "cropped_image" },
    loadError: String,
    processError: String
  }

  connect() {
    this.currentFile = null
    this.currentPreviewUrl = null
    this.editorUrl = null
    this.dragging = false
  }

  disconnect() {
    this.revokeUrl("currentPreviewUrl")
    this.revokeUrl("editorUrl")
    document.body.classList.remove("overflow-hidden")
  }

  select() {
    const file = this.inputTarget.files[0]

    if (!file) return

    if (!file.type.startsWith("image/")) {
      this.inputTarget.value = ""
      this.openModal()
      this.cropBoxTarget.classList.add("hidden")
      this.applyButtonTarget.disabled = true
      this.showError(this.loadErrorValue)
      return
    }

    this.pendingFileName = file.name
    this.inputTarget.value = ""
    this.openEditor(file)
  }

  cancel() {
    this.restoreCurrentFile()
    this.closeEditor()
  }

  async apply() {
    this.applyButtonTarget.disabled = true
    this.clearError()

    try {
      const blob = await this.createCroppedBlob()
      const file = new File([blob], this.croppedFileName(), { type: blob.type || MIME_TYPE })

      this.setInputFile(file)
      this.currentFile = file
      this.showPreview(file)

      if (this.hasRemoveFieldTarget) this.removeFieldTarget.value = "0"
      if (this.hasRemoveButtonTarget) this.removeButtonTarget.classList.remove("hidden")

      this.closeEditor()
    } catch {
      this.showError(this.processErrorValue)
    } finally {
      this.applyButtonTarget.disabled = false
    }
  }

  remove(event) {
    event.preventDefault()

    this.currentFile = null
    this.inputTarget.value = ""

    if (this.hasRemoveFieldTarget) this.removeFieldTarget.value = "1"

    this.imageTarget.removeAttribute("src")
    this.imageTarget.classList.add("hidden")
    this.placeholderTarget.classList.remove("hidden")
    this.placeholderTarget.classList.add("flex")

    if (this.hasRemoveButtonTarget) this.removeButtonTarget.classList.add("hidden")
  }

  startDrag(event) {
    event.preventDefault()

    this.dragging = true
    this.dragStartX = event.clientX
    this.dragStartY = event.clientY
    this.startCropX = this.cropX
    this.startCropY = this.cropY
    this.cropBoxTarget.setPointerCapture(event.pointerId)
  }

  drag(event) {
    if (!this.dragging) return

    this.cropX = this.startCropX + event.clientX - this.dragStartX
    this.cropY = this.startCropY + event.clientY - this.dragStartY
    this.clampCropBox()
    this.updateCropBox()
  }

  endDrag(event) {
    if (!this.dragging) return

    this.dragging = false
    this.cropBoxTarget.releasePointerCapture(event.pointerId)
  }

  openEditor(file) {
    this.clearError()
    this.openModal()
    this.cropBoxTarget.classList.add("hidden")
    this.applyButtonTarget.disabled = true
    this.revokeUrl("editorUrl")
    this.editorUrl = URL.createObjectURL(file)

    this.sourceImageTarget.onload = () => {
      requestAnimationFrame(() => this.setupEditor())
    }

    this.sourceImageTarget.onerror = () => {
      this.restoreCurrentFile()
      this.showError(this.loadErrorValue)
    }

    this.sourceImageTarget.src = this.editorUrl
  }

  openModal() {
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    document.body.classList.add("overflow-hidden")
  }

  closeEditor() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    document.body.classList.remove("overflow-hidden")
    this.sourceImageTarget.removeAttribute("src")
    this.cropBoxTarget.classList.add("hidden")
    this.revokeUrl("editorUrl")
    this.clearError()
  }

  setupEditor() {
    const frameRect = this.frameTarget.getBoundingClientRect()
    const imageAspect = this.sourceImageTarget.naturalWidth / this.sourceImageTarget.naturalHeight
    const frameAspect = frameRect.width / frameRect.height

    this.frameWidth = frameRect.width
    this.frameHeight = frameRect.height

    if (imageAspect > frameAspect) {
      this.displayWidth = frameRect.width
      this.displayHeight = frameRect.width / imageAspect
    } else {
      this.displayHeight = frameRect.height
      this.displayWidth = frameRect.height * imageAspect
    }

    this.imageX = (frameRect.width - this.displayWidth) / 2
    this.imageY = (frameRect.height - this.displayHeight) / 2

    this.sourceImageTarget.style.left = `${this.imageX}px`
    this.sourceImageTarget.style.top = `${this.imageY}px`
    this.sourceImageTarget.style.width = `${this.displayWidth}px`
    this.sourceImageTarget.style.height = `${this.displayHeight}px`

    this.setupCropBox()
    this.applyButtonTarget.disabled = false
  }

  setupCropBox() {
    const cropAspect = this.outputWidthValue / this.outputHeightValue
    const displayAspect = this.displayWidth / this.displayHeight

    if (displayAspect > cropAspect) {
      this.cropHeight = this.displayHeight
      this.cropWidth = this.cropHeight * cropAspect
    } else {
      this.cropWidth = this.displayWidth
      this.cropHeight = this.cropWidth / cropAspect
    }

    this.cropX = this.imageX + (this.displayWidth - this.cropWidth) / 2
    this.cropY = this.imageY + (this.displayHeight - this.cropHeight) / 2
    this.updateCropBox()
  }

  updateCropBox() {
    this.cropBoxTarget.style.left = `${this.cropX}px`
    this.cropBoxTarget.style.top = `${this.cropY}px`
    this.cropBoxTarget.style.width = `${this.cropWidth}px`
    this.cropBoxTarget.style.height = `${this.cropHeight}px`
    this.cropBoxTarget.classList.remove("hidden")
  }

  clampCropBox() {
    const minX = this.imageX
    const minY = this.imageY
    const maxX = this.imageX + this.displayWidth - this.cropWidth
    const maxY = this.imageY + this.displayHeight - this.cropHeight

    this.cropX = Math.min(maxX, Math.max(minX, this.cropX))
    this.cropY = Math.min(maxY, Math.max(minY, this.cropY))
  }

  async createCroppedBlob() {
    const canvas = document.createElement("canvas")
    canvas.width = this.outputWidthValue
    canvas.height = this.outputHeightValue

    const context = canvas.getContext("2d")
    const source = this.cropSourceRect()

    context.drawImage(
      this.sourceImageTarget,
      source.x,
      source.y,
      source.width,
      source.height,
      0,
      0,
      canvas.width,
      canvas.height
    )

    return this.canvasToBlob(canvas)
  }

  cropSourceRect() {
    const naturalWidth = this.sourceImageTarget.naturalWidth
    const naturalHeight = this.sourceImageTarget.naturalHeight

    return {
      x: (this.cropX - this.imageX) / this.displayWidth * naturalWidth,
      y: (this.cropY - this.imageY) / this.displayHeight * naturalHeight,
      width: this.cropWidth / this.displayWidth * naturalWidth,
      height: this.cropHeight / this.displayHeight * naturalHeight
    }
  }

  canvasToBlob(canvas) {
    return new Promise((resolve, reject) => {
      canvas.toBlob((blob) => {
        if (blob) {
          resolve(blob)
        } else {
          reject(new Error("Canvas export failed"))
        }
      }, MIME_TYPE, this.qualityValue)
    })
  }

  setInputFile(file) {
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.inputTarget.files = dataTransfer.files
  }

  restoreCurrentFile() {
    if (this.currentFile) {
      this.setInputFile(this.currentFile)
    } else {
      this.inputTarget.value = ""
    }
  }

  showPreview(file) {
    this.revokeUrl("currentPreviewUrl")
    this.currentPreviewUrl = URL.createObjectURL(file)

    this.imageTarget.src = this.currentPreviewUrl
    this.imageTarget.classList.remove("hidden")
    this.placeholderTarget.classList.add("hidden")
  }

  croppedFileName() {
    const baseName = (this.pendingFileName || this.fileNameValue).replace(/\.[^.]+$/, "")
    return `${baseName}.${FILE_EXTENSION}`
  }

  showError(message) {
    if (!this.hasErrorTarget) return

    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  clearError() {
    if (!this.hasErrorTarget) return

    this.errorTarget.textContent = ""
    this.errorTarget.classList.add("hidden")
  }

  revokeUrl(propertyName) {
    if (!this[propertyName]) return

    URL.revokeObjectURL(this[propertyName])
    this[propertyName] = null
  }
}
