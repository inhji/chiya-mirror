defmodule ChiyaWeb.Markdown do

	@options [
		footnotes: true,
		breaks: true,
		escape: true
	]

	def render(markdown) do
		markdown
		|> Earmark.as_html!(@options)
	end

end