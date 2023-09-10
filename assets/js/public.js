// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'

import hljs from 'highlight.js'
import GLightbox from 'glightbox'
import Tablesort from 'tablesort'
import darkmode from "./darkmode"

document.addEventListener('DOMContentLoaded', (event) => {
  document.querySelectorAll('.prose pre code').forEach((el) => 
    hljs.highlightElement(el))

  document.querySelectorAll('.prose table').forEach(el => 
  	new Tablesort(el))

  darkmode()

  GLightbox({ selector: '.lightbox' })
});