# frozen_string_literal: true

require 'octicons'
require 'cssminify'
#require 'liquid/template'

ADMONITION_ICONS = {
  'important' => 'report',
  'note' => 'info',
  'tip' => 'light-bulb',
  'warning' => 'alert',
  'caution' => 'stop'
}.freeze

module Jekyll
  class GFMAdmonitionConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /^\.(md|markdown)$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      original_content = content.dup
      content.gsub!(/<blockquote>\s*<p>\s*\[!(IMPORTANT|NOTE|WARNING|TIP|CAUTION)\](.*?)$\n(.*?)\s*<\/p>\s*<\/blockquote>/m) do
        type = ::Regexp.last_match(1).downcase
        title = ::Regexp.last_match(2).strip.empty? ? type.capitalize : ::Regexp.last_match(2).strip
        text = ::Regexp.last_match(3)
        icon = Octicons::Octicon.new(ADMONITION_ICONS[type]).to_svg
        admonition_html(type, title, text, icon)
      end

      if content != original_content
        css = File.read(File.expand_path('../assets/admonitions.css', __dir__))
        content = "<head><style>#{CSSminify.compress(css)}</style></head>" + content
      end

      content
    end

    def admonition_html(type, title, text, icon)
      "<div class='markdown-alert markdown-alert-#{type}'>" \
        "<p class='markdown-alert-title'>#{icon} #{title}</p>" \
        "#{text}" \
      "</div>"
    end
  end
end