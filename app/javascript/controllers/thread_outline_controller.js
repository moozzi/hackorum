import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.activeItem = null
    this.setupObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupObserver() {
    const options = {
      root: null,
      rootMargin: "-20% 0px -60% 0px",
      threshold: 0
    }

    this.observer = new IntersectionObserver((entries) => {
      this.handleIntersection(entries)
    }, options)

    document.querySelectorAll(".message-card[id^='message-']").forEach((card) => {
      this.observer.observe(card)
    })
  }

  handleIntersection(entries) {
    let visibleMessages = []

    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        visibleMessages.push({
          element: entry.target,
          top: entry.boundingClientRect.top
        })
      }
    })

    if (visibleMessages.length === 0) return

    visibleMessages.sort((a, b) => a.top - b.top)
    const topMessage = visibleMessages[0].element
    const messageId = topMessage.id.replace("message-", "")

    this.highlightOutlineItem(messageId)
  }

  highlightOutlineItem(messageId) {
    if (this.activeItem) {
      this.activeItem.classList.remove("outline-active")
    }
    if (this.activeSummary) {
      this.activeSummary.classList.remove("outline-active")
    }

    const outlineItem = this.element.querySelector(`a[href="#message-${messageId}"]`)
    if (outlineItem) {
      const itemContainer = outlineItem.closest(".outline-item") || outlineItem
      itemContainer.classList.add("outline-active")
      this.activeItem = itemContainer

      const parentDetails = outlineItem.closest("details.branch-details")
      if (parentDetails) {
        const summary = parentDetails.querySelector(":scope > summary")
        if (summary) {
          summary.classList.add("outline-active")
          this.activeSummary = summary
        }
      }
    }
  }
}
