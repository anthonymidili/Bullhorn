import { Controller } from "@hotwired/stimulus"
import Tribute from "tributejs"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.isFormatting = false
    this.resizeObservers = []

    this.boundTrixInit = this.handleTrixInit.bind(this)
    this.boundTrixChange = this.handleTrixChange.bind(this)
    this.boundTrixSelectionChange = this.handleTrixSelectionChange.bind(this)

    this.element.addEventListener("trix-initialize", this.boundTrixInit)
    this.element.addEventListener("trix-change", this.boundTrixChange)
    this.element.addEventListener("trix-selection-change", this.boundTrixSelectionChange)

    this.initTribute()
    this.initHighlighters()
  }

  disconnect() {
    this.element.removeEventListener("trix-initialize", this.boundTrixInit)
    this.element.removeEventListener("trix-change", this.boundTrixChange)
    this.element.removeEventListener("trix-selection-change", this.boundTrixSelectionChange)

    if (this.resizeObservers) {
      this.resizeObservers.forEach(ro => ro.disconnect())
      this.resizeObservers = []
    }

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
      const currentRange = editor.getSelectedRange()

      // 1. Unlink any invalid hashtag or mention pieces
      if (doc.getPieces) {
        let offset = 0
        const invalidRanges = []
        doc.getPieces().forEach(piece => {
          const len = piece.length || (piece.string ? piece.string.length : 0)
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

      // Match hashtags: #tag
      const hashtagRegex = /(?<=^|[^\w#])#([a-zA-Z0-9_]+)\b/g
      let match
      while ((match = hashtagRegex.exec(currentText)) !== null) {
        const tag = match[1]
        const start = match.index
        const end = start + tag.length + 1
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

  initHighlighters() {
    const elements = this.getTargetElements()
    elements.forEach(el => {
      if (el.tagName.toLowerCase() === "textarea") {
        this.setupTextareaHighlighter(el)
      } else if (el.tagName.toLowerCase() === "trix-editor") {
        this.setupTrixEditor(el)
      }
    })
  }

  setupTextareaHighlighter(textarea) {
    if (textarea.dataset.highlighterInitialized) return
    textarea.dataset.highlighterInitialized = "true"

    // Create wrapper container
    const wrapper = document.createElement("div")
    wrapper.className = "tag-highlighter-wrapper"

    textarea.parentNode.insertBefore(wrapper, textarea)
    wrapper.appendChild(textarea)

    // Create backdrop container
    const backdrop = document.createElement("div")
    backdrop.className = "tag-highlighter-backdrop"
    wrapper.insertBefore(backdrop, textarea)

    textarea.classList.add("tag-highlighter-input")

    const syncStyles = () => {
      const style = window.getComputedStyle(textarea)
      backdrop.style.fontFamily = style.fontFamily
      backdrop.style.fontSize = style.fontSize
      backdrop.style.fontWeight = style.fontWeight
      backdrop.style.lineHeight = style.lineHeight
      backdrop.style.letterSpacing = style.letterSpacing
      backdrop.style.paddingTop = style.paddingTop
      backdrop.style.paddingRight = style.paddingRight
      backdrop.style.paddingBottom = style.paddingBottom
      backdrop.style.paddingLeft = style.paddingLeft
      backdrop.style.borderWidth = style.borderWidth
      backdrop.style.borderStyle = "solid"
      backdrop.style.borderColor = "transparent"
      backdrop.style.boxSizing = style.boxSizing
      backdrop.style.borderRadius = style.borderRadius
    }

    const updateBackdrop = () => {
      backdrop.innerHTML = this.highlightText(textarea.value)
    }

    const syncScroll = () => {
      backdrop.scrollTop = textarea.scrollTop
      backdrop.scrollLeft = textarea.scrollLeft
    }

    syncStyles()
    updateBackdrop()

    textarea.addEventListener("input", updateBackdrop)
    textarea.addEventListener("scroll", syncScroll)

    if (window.ResizeObserver) {
      const ro = new ResizeObserver(() => {
        backdrop.style.width = textarea.offsetWidth + "px"
        backdrop.style.height = textarea.offsetHeight + "px"
        syncStyles()
      })
      ro.observe(textarea)
      this.resizeObservers.push(ro)
    }
  }

  highlightText(text) {
    if (!text) return ""

    let escaped = text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")

    // Highlight mentions: @username
    escaped = escaped.replace(/(?<=^|[^\w@])@([a-zA-Z0-9_]{1,30})\b/g, '<span class="mention-link">@$1</span>')

    // Highlight hashtags: #hashtag
    escaped = escaped.replace(/(?<=^|[^\w#])#([a-zA-Z0-9_]+)\b/g, '<span class="hashtag-link">#$1</span>')

    // Ensure trailing newline renders with proper height
    if (text.endsWith("\n")) {
      escaped += "<br>&nbsp;"
    }

    return escaped
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
