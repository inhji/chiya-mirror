export default function() {
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
}