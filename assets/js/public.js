// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'

import hljs from 'highlight.js'
import GLightbox from 'glightbox'
import Tablesort from 'tablesort'

document.addEventListener('DOMContentLoaded', (event) => {
  document.querySelectorAll('.prose pre code').forEach((el) => 
    hljs.highlightElement(el))

  document.querySelectorAll('.prose table').forEach(el => 
  	new Tablesort(el))
});

document
	.querySelector('#dark-mode-toggle')
	.addEventListener('click', (e) => {
		e.preventDefault()
		const data = document.documentElement.dataset
		if (data['mode'] && data['mode'] == 'dark') {
			delete data['mode']
			window.localStorage.removeItem('theme')
		} else {
			data['mode'] = 'dark'
			window.localStorage.setItem('theme', 'dark')
		}
	})

GLightbox({ selector: '.lightbox' })

window.hljs = hljs