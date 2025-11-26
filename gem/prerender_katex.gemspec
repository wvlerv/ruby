require_relative "prerender_katex"

Gem::Specification.new do |s|
  s.name        = "prerender_katex"
  s.version     = PrerenderKatex::VERSION
  s.summary     = "KaTeX prerendering for Markdown (CLI + fallback)"
  s.files       = ["prerender_katex.rb", "test_renderer.rb", "demo.rb"]
  s.require_paths = ["."]
  s.add_runtime_dependency "kramdown"
end