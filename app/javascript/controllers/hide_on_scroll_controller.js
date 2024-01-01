import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hide-on-scroll"
export default class extends Controller {
  connect() {
    function debounce(func, wait = 10, immediate = true) {
      let timeout
      return function() {
        let context = this, args = arguments
        let later = function() {
          timeout = null
          if (!immediate) func.apply(context, args)
        }
        let callNow = immediate && !timeout
        clearTimeout(timeout)
        timeout = setTimeout(later, wait)
        if (callNow) func.apply(context, args)
      }
    }
  
    let scrollPos = 0
    const nav = document.querySelector('#new-post-btn')
  
    function checkPosition() {
      let windowY = window.scrollY
      if (windowY < scrollPos) {
        // Scrolling UP
        nav.classList.add('transition-visible')
        nav.classList.remove('transition-hidden')
      } else {
        // Scrolling DOWN
        nav.classList.add('transition-hidden')
        nav.classList.remove('transition-visible')
      }
      scrollPos = windowY
    }
  
    // window.addEventListener('scroll', checkPosition);
    window.addEventListener('scroll', debounce(checkPosition))
  }
}
