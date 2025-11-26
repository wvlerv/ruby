require "kramdown"
require "open3"

module PrerenderKatex
  VERSION = "0.1.0"

  class Renderer
    def initialize(opts = {})
      @katex = opts[:katex_path] || "katex"
      @fallback = opts.fetch(:fallback, true)
    end

    def render(markdown)
      parts = extract_math(markdown)

      html = parts.map do |p|
        if p[:type] == :text
          Kramdown::Document.new(p[:content]).to_html
        else
          render_math(p[:content], p[:display])
        end
      end.join

      html
    end

    private

    def extract_math(text)
      arr = []
      i = 0

      while i < text.length
        if (m = text.index("$$", i))
          arr << { type: :text, content: text[i...m] } if m > i
          close = text.index("$$", m + 2)
          break unless close
          math = text[(m + 2)...close]
          arr << { type: :math, content: math, display: true }
          i = close + 2
        elsif (m = text.index("$", i))
          arr << { type: :text, content: text[i...m] } if m > i
          close = find_dollar(text, m + 1)
          break unless close
          math = text[(m + 1)...close]
          arr << { type: :math, content: math, display: false }
          i = close + 1
        else
          arr << { type: :text, content: text[i..] }
          break
        end
      end

      arr
    end

    def find_dollar(text, start)
      (start...text.length).each do |i|
        return i if text[i] == "$" && text[i - 1] != "\\"
      end
      nil
    end

    def render_math(math, display)
      html = render_with_cli(math, display)
      return html unless html.nil?

      return fallback_html(math, display) if @fallback

      ""
    end

    def render_with_cli(math, display)
      cmd = [@katex, "--no-throw-on-error"]
      cmd << "--display-mode" if display

      stdout, stderr, status = Open3.capture3(*cmd, stdin_data: math)
      return stdout if status.success?

      nil
    rescue Errno::ENOENT
      nil
    end

    def fallback_html(math, display)
      escaped = math
        .gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")

      if display
        "<div class=\"katex-fallback\">$$#{escaped}$$</div>"
      else
        "<span class=\"katex-fallback\">$#{escaped}$</span>"
      end
    end
  end
end