require_relative "prerender_katex"

markdown = <<~MD
# Demo: Only Formulas

Inline formula 1: $e^{i\\pi} + 1 = 0$

Inline formula 2: $a^2 + b^2 = c^2$

Block formula 1:

$$
\\int_0^1 x dx = 1/2
$$

Block formula 2:

$$
\\frac{d}{dx} e^x = e^x
$$

Inline formula 3: $F = ma$
MD

renderer = PrerenderKatex::Renderer.new
puts renderer.render(markdown)