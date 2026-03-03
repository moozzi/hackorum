import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "nameInput"]
  static values = { url: String }

  toggle() {
    this.formTarget.classList.toggle("is-hidden")
    if (!this.formTarget.classList.contains("is-hidden")) {
      this.nameInputTarget.focus()
    }
  }

  async submit(event) {
    event.preventDefault()
    const form = event.target.closest("form") || event.target
    const formData = new FormData(form)

    const response = await fetch(this.urlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      },
      body: formData
    })

    if (response.ok) {
      const data = await response.json()
      window.location.href = data.redirect_url
    } else {
      const data = await response.json().catch(() => null)
      const message = data?.errors?.join(", ") || "Failed to save search"
      this.formTarget.insertAdjacentHTML("beforeend", `<p class="save-search-error">${message}</p>`)
    }
  }
}
