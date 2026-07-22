import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "dropzone", "preview", "previewImage", "previewChip", "previewName", "removeButton", "placeholder" ]

  dragOver(event) {
    event.preventDefault()
    this.dropzoneTarget.setAttribute("data-dragover", "")
  }

  dragLeave(event) {
    event.preventDefault()
    this.dropzoneTarget.removeAttribute("data-dragover")
  }

  drop(event) {
    event.preventDefault()
    this.dropzoneTarget.removeAttribute("data-dragover")
    const file = event.dataTransfer?.files?.[0]
    if (!file) return
    this.inputTarget.files = event.dataTransfer.files
    this.showPreview(file)
  }

  change() {
    const file = this.inputTarget.files?.[0]
    if (file) this.showPreview(file)
  }

  remove(event) {
    event.preventDefault()
    event.stopPropagation()
    this.inputTarget.value = ""
    this.previewTarget.hidden = true
    this.placeholderTarget.hidden = false
    this.removeButtonTarget.hidden = true
    this.dispatch("remove")
  }

  showPreview(file) {
    this.placeholderTarget.hidden = true
    this.previewTarget.hidden = false
    this.removeButtonTarget.hidden = false

    const isImage = file.type.startsWith("image/")
    this.previewImageTarget.hidden = !isImage
    this.previewChipTarget.hidden = isImage

    if (isImage) {
      const reader = new FileReader()
      reader.onload = () => { this.previewImageTarget.src = reader.result }
      reader.readAsDataURL(file)
    } else {
      this.previewNameTarget.textContent = file.name
    }

    this.dispatch("change", { detail: { file } })
  }
}
