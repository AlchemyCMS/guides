require 'kramdown/parser/kramdown'

class Kramdown::Parser::GuidesMarkdown < Kramdown::Parser::Kramdown
  NOTE_REGEX = /^(IMPORTANT|CAUTION|WARNING|NOTE|INFO|TIP)[.:](.*)/
  define_parser(:guides_info_block, NOTE_REGEX)

  def initialize(source, options)
    super
    @block_parsers.unshift(:guides_info_block)
  end

  def parse_guides_info_block
    @src.pos += @src.matched_size

    _, type, body = @src.matched.match(NOTE_REGEX).to_a

    css_class = type.to_s.downcase
    css_class = 'warning' if ['caution', 'important'].include?(css_class)
    css_class = 'info' if css_class == 'tip'

    if body
      result = %{<div class="#{css_class}">}
      result << Document.new(body).to_html
      result << '</div>'
    end

    if result
      @tree.children << Element.new(:raw, result)
    end
  end
end
