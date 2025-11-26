require "minitest/autorun"
require_relative "prerender_katex"

class TestRenderer < Minitest::Test
  def setup
    @renderer = PrerenderKatex::Renderer.new(katex_path: "none", fallback: true)
  end

  def test_inline_fallback
    html = @renderer.render("Math: $x+1$")
    assert_includes html, "katex-fallback"
    assert_includes html, "x+1"
  end

  def test_display_fallback
    html = @renderer.render("$$x^2$$")
    assert_includes html, "katex-fallback"
    assert_includes html, "x^2"
  end

  def test_text_without_math
    html = @renderer.render("This is a plain text without math.")
    assert_includes html, "This is a plain text without math."
    refute_includes html, "katex-fallback"
  end

  def test_mixed_inline_and_block
    md = <<~MD
      Here is inline $a+b$ and block:

      $$
      c = \\sqrt{a^2 + b^2}
      $$
    MD

    html = @renderer.render(md)
    assert_includes html, "katex-fallback"
    assert_includes html, "a+b"
    assert_includes html, "c = \\sqrt{a^2 + b^2}"
  end

  def test_multiple_inline
    html = @renderer.render("Sum: $x$ + $y$ = $z$")
    occurrences = html.scan("katex-fallback").size
    assert_equal 3, occurrences
    assert_includes html, "x"
    assert_includes html, "y"
    assert_includes html, "z"
  end

  def test_inline_with_text
    html = @renderer.render("Equation $E=mc^2$ in text.")
    assert_includes html, "katex-fallback"
    assert_includes html, "E=mc^2"
    assert_includes html, "in text"
  end

  def test_block_with_surrounding_text
    md = <<~MD
      Before block math.

      $$
      y = mx + b
      $$

      After block math.
    MD

    html = @renderer.render(md)
    assert_includes html, "katex-fallback"
    assert_includes html, "y = mx + b"
    assert_includes html, "Before block math."
    assert_includes html, "After block math."
  end

  def test_multiple_blocks
    md = <<~MD
      First block:

      $$
      a^2 + b^2 = c^2
      $$

      Second block:

      $$
      \\int_0^1 x dx
      $$
    MD

    html = @renderer.render(md)
    blocks = html.scan("katex-fallback").size
    assert_equal 2, blocks
    assert_includes html, "a^2 + b^2 = c^2"
    assert_includes html, "\\int_0^1 x dx"
  end
end