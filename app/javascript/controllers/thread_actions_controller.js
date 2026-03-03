import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    topicId: Number,
    readAllUrl: String,
  }

  markAllRead(event) {
    event.preventDefault()
    document.querySelectorAll(".message-content").forEach(el => el.classList.add("is-read"))
    document.querySelectorAll(".message-card").forEach(card => {
      const controller = this.application.getControllerForElementAndIdentifier(card, "message-collapse")
      if (controller) {
        controller.collapsedValue = true
      }
    })
    this.post(this.readAllUrlValue)
  }

  post(url, onSuccess) {
    fetch(url, {
      method: "POST",
      headers: this.csrfHeaders(),
    }).then(resp => {
      if (resp.ok && onSuccess) onSuccess()
    }).catch(e => console.warn("thread action failed", e))
  }

  csrfHeaders() {
    const token = document.querySelector("meta[name=csrf-token]")?.content
    return token ? { "X-CSRF-Token": token } : {}
  }
}
