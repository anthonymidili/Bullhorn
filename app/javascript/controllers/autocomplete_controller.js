import { Controller } from "@hotwired/stimulus"
import Tribute from "tributejs"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.isFormatting = false

    this.boundTrixInit = this.handleTrixInit.bind(this)
    this.boundTrixChange = this.handleTrixChange.bind(this)
    this.boundTrixSelectionChange = this.handleTrixSelectionChange.bind(this)

    this.element.addEventListener("trix-initialize", this.boundTrixInit)
    this.element.addEventListener("trix-change", this.boundTrixChange)
    this.element.addEventListener("trix-selection-change", this.boundTrixSelectionChange)

    this.initTribute()
  }

  disconnect() {
    this.element.removeEventListener("trix-initialize", this.boundTrixInit)
    this.element.removeEventListener("trix-change", this.boundTrixChange)
    this.element.removeEventListener("trix-selection-change", this.boundTrixSelectionChange)

    if (this.tribute) {
      const elements = this.getTargetElements()
      elements.forEach(el => {
        try {
          this.tribute.detach(el)
        } catch (e) {}
      })
    }
  }

  handleTrixInit(event) {
    const el = event.target
    if (el) {
      this.setupTrixEditor(el)
    }
  }

  handleTrixChange(event) {
    const editor = event.target.editor
    if (editor) {
      this.formatTrixTags(editor)
    }
  }

  handleTrixSelectionChange(event) {
    if (this.isFormatting) return
    const editor = event.target.editor
    if (!editor) return

    const range = editor.getSelectedRange()
    if (!range || range[0] !== range[1]) return

    const pos = range[0]
    if (pos === 0) {
      editor.deactivateAttribute("href")
      return
    }

    const charBefore = editor.getDocument().getStringAtRange([pos - 1, pos])
    if (/[\s.,!?]/.test(charBefore)) {
      editor.deactivateAttribute("href")
    }
  }

  setupTrixEditor(el) {
    if (el.dataset.trixAutocompleteInitialized) return
    el.dataset.trixAutocompleteInitialized = "true"

    if (this.tribute) {
      try {
        this.tribute.attach(el)
      } catch (e) {}
    }

    const formatEditor = () => {
      if (el.editor) {
        this.formatTrixTags(el.editor)
      }
    }

    if (el.editor) {
      setTimeout(formatEditor, 30)
    } else {
      el.addEventListener("trix-initialize", () => setTimeout(formatEditor, 30), { once: true })
    }
  }

  formatTrixTags(editor) {
    if (this.isFormatting || !editor) return
    this.isFormatting = true
    try {
      const doc = editor.getDocument()
      if (!doc) return

      // Never format while attachments are uploading / pending
      if (doc.getAttachments) {
        const attachments = doc.getAttachments()
        if (attachments && attachments.some(a => a.isPending && a.isPending())) {
          return
        }
      }

      const currentRange = editor.getSelectedRange()

      // 1. Unlink any invalid hashtag or mention pieces (skip attachment pieces)
      if (doc.getPieces) {
        let offset = 0
        const invalidRanges = []
        doc.getPieces().forEach(piece => {
          const len = piece.length || (piece.string ? piece.string.length : 0)
          if (piece.attachment) {
            offset += len
            return
          }

          const href = piece.attributes && piece.attributes.href
          if (href) {
            if (href.startsWith("/hashtags/")) {
              if (!piece.string || !piece.string.startsWith("#") || piece.string.length <= 1) {
                invalidRanges.push([offset, offset + len])
              }
            } else if (href.startsWith("/users/") || href.startsWith("/@")) {
              if (!piece.string || !piece.string.startsWith("@") || piece.string.length <= 1) {
                invalidRanges.push([offset, offset + len])
              }
            }
          }
          offset += len
        })
        invalidRanges.forEach(range => {
          editor.setSelectedRange(range)
          editor.deactivateAttribute("href")
        })
      }

      const currentDoc = editor.getDocument()
      const currentText = currentDoc.toString()
      const toLink = []

      const overlapsAttachment = (start, end) => {
        if (!currentDoc.getPieces) return false
        let pOffset = 0
        for (const piece of currentDoc.getPieces()) {
          const pLen = piece.length || (piece.string ? piece.string.length : 0)
          if (piece.attachment) {
            if (start < pOffset + pLen && end > pOffset) {
              return true
            }
          }
          pOffset += pLen
        }
        return false
      }

      // Match hashtags: #tag
      const hashtagRegex = /(?<=^|[^\w#])#([a-zA-Z0-9_]+)\b/g
      let match
      while ((match = hashtagRegex.exec(currentText)) !== null) {
        const tag = match[1]
        const start = match.index
        const end = start + tag.length + 1
        if (overlapsAttachment(start, end)) continue

        const attrs = currentDoc.getCommonAttributesAtRange([start, end])
        const expectedHref = `/hashtags/${tag}`
        if (attrs.href !== expectedHref) {
          toLink.push({ start, end, href: expectedHref })
        }
      }

      // Match mentions: @username
      const mentionRegex = /(?<=^|[^\w@])@([a-zA-Z0-9_]{1,30})\b/g
      while ((match = mentionRegex.exec(currentText)) !== null) {
        const username = match[1]
        const start = match.index
        const end = start + username.length + 1
        if (overlapsAttachment(start, end)) continue

        const attrs = currentDoc.getCommonAttributesAtRange([start, end])
        const expectedHref = `/users/${username}`
        if (attrs.href !== expectedHref) {
          toLink.push({ start, end, href: expectedHref })
        }
      }

      if (toLink.length > 0) {
        toLink.forEach(item => {
          editor.setSelectedRange([item.start, item.end])
          editor.activateAttribute("href", item.href)
        })
      }

      if (currentRange) {
        editor.setSelectedRange(currentRange)
      }

      if (currentRange && currentRange[0] === currentRange[1]) {
        const pos = currentRange[0]
        if (pos > 0) {
          const charBefore = editor.getDocument().getStringAtRange([pos - 1, pos])
          if (/[\s.,!?]/.test(charBefore)) {
            editor.deactivateAttribute("href")
          }
        }
      }
    } finally {
      this.isFormatting = false
    }
  }

  handleTributeSelect(item, triggerChar, prefixUrl) {
    if (typeof item === "undefined" || !item) return null

    const el = this.tribute?.current?.element
    if (!el || el.tagName.toLowerCase() !== "trix-editor" || !el.editor) {
      return `${triggerChar}${item.original.value} `
    }

    const editor = el.editor
    this.isFormatting = true
    try {
      const range = editor.getSelectedRange()
      const pos = range ? range[0] : 0
      const lookbackStart = Math.max(0, pos - 50)
      const textBefore = editor.getDocument().getStringAtRange([lookbackStart, pos])
      const lastTriggerIndex = textBefore.lastIndexOf(triggerChar)

      const safeValue = item.original.value
      const url = `${prefixUrl}${encodeURIComponent(safeValue)}`
      const htmlToInsert = `<a href="${url}">${triggerChar}${safeValue}</a>&nbsp;`

      if (lastTriggerIndex !== -1) {
        const triggerPos = lookbackStart + lastTriggerIndex
        editor.setSelectedRange([triggerPos, pos])
        editor.insertHTML(htmlToInsert)
      } else {
        editor.insertHTML(htmlToInsert)
      }
      editor.deactivateAttribute("href")
    } finally {
      this.isFormatting = false
    }
    return null
  }

  getTargetElements() {
    const elements = []
    if (this.hasInputTarget) {
      if (this.inputTarget.tagName.toLowerCase() === "trix-editor") {
        elements.push(this.inputTarget)
      } else {
        const trix = this.inputTarget.querySelector("trix-editor")
        if (trix) {
          elements.push(trix)
        } else {
          elements.push(this.inputTarget)
        }
      }
    } else {
      const trixEditors = this.element.querySelectorAll("trix-editor")
      if (trixEditors.length > 0) {
        trixEditors.forEach(el => elements.push(el))
      }
      const textareas = this.element.querySelectorAll("textarea")
      if (textareas.length > 0) {
        textareas.forEach(el => elements.push(el))
      }
    }
    return elements
  }

  initTribute() {
    this.tribute = new Tribute({
      collection: [
        {
          trigger: "@",
          values: (text, cb) => {
            fetch(`/users/mentions?term=${encodeURIComponent(text)}`, {
              headers: { "Accept": "application/json" }
            })
              .then(res => res.json())
              .then(data => cb(data))
              .catch(() => cb([]))
          },
          lookup: "key",
          fillAttr: "value",
          selectTemplate: (item) => this.handleTributeSelect(item, "@", "/users/"),
          menuItemTemplate: (item) => {
            return `
              <div class="d-flex align-items-center gap-2 py-1 px-1">
                <img src="${item.original.avatar_url}" class="rounded-circle border" width="28" height="28" style="object-fit: cover;" />
                <div class="text-start">
                  <div class="fw-bold fs-6 lh-1">@${item.original.value}</div>
                  <small class="text-muted lh-1">${item.original.name || ""}</small>
                </div>
              </div>
            `
          },
          noMatchTemplate: () => '<span style="display:none;"></span>'
        },
        {
          trigger: "#",
          values: (text, cb) => {
            fetch(`/hashtags/search?term=${encodeURIComponent(text)}`, {
              headers: { "Accept": "application/json" }
            })
              .then(res => res.json())
              .then(data => cb(data))
              .catch(() => cb([]))
          },
          lookup: "key",
          fillAttr: "value",
          selectTemplate: (item) => this.handleTributeSelect(item, "#", "/hashtags/"),
          menuItemTemplate: (item) => {
            return `
              <div class="d-flex align-items-center justify-content-between gap-3 py-1 px-1">
                <span class="fw-bold text-primary">#${item.original.value}</span>
                <span class="badge bg-secondary rounded-pill">${item.original.count || 0}</span>
              </div>
            `
          },
          noMatchTemplate: () => '<span style="display:none;"></span>'
        }
      ]
    })

    const elements = this.getTargetElements()
    elements.forEach(el => {
      this.tribute.attach(el)
      if (el.tagName.toLowerCase() === "trix-editor") {
        this.setupTrixEditor(el)
      }
    })
  }
}
