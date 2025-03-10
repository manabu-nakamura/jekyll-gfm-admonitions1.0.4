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
    priority :lowest
#    @admonition_pages = []

=begin
    class << self
      attr_reader :admonition_pages
    end
=end

    def matches(ext)
      ext =~ /^\.(md|markdown)$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      original_content = content.dup
      content.gsub!(/<blockquote>\s*<p>\s*\[!(IMPORTANT|NOTE|WARNING|TIP|CAUTION)\](.*?)\n(.*?)\s*<\/p>\s*<\/blockquote>/m) do
        type = ::Regexp.last_match(1).downcase
        title = ::Regexp.last_match(2).strip.empty? ? type.capitalize : ::Regexp.last_match(2).strip
        text = ::Regexp.last_match(3)
        icon = Octicons::Octicon.new(ADMONITION_ICONS[type]).to_svg
        admonition_html(type, title, text, icon)
      end
      if content != original_content
        css = File.read(File.expand_path('../assets/admonitions.css', __dir__))
        content = "<head><style>#{CSSminify.compress(css)}</style></head>" + content
#        self.class.admonition_pages << content.page
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

=begin
  # Insert the minified CSS before the closing head tag of all pages we put admonitions on
  Jekyll::Hooks.register :site, :post_render do
    Jekyll.logger.info 'GFMA:', "Inserting admonition CSS in #{GFMAdmonitionConverter.admonition_pages.length} page(s)."

    GFMAdmonitionConverter.admonition_pages.each do |page|
      Jekyll.logger.debug 'GFMA:', "Appending admonition style to '#{page.path}'."
      css = File.read(File.expand_path('../assets/admonitions.css', __dir__))

      page.output.gsub!(%r{<head>(.*?)</head>}m) do |match|
        head = Regexp.last_match(1)
        "<head>#{head}<style>#{CSSminify.compress(css)}</style></head>"
      end

      # If no <head> tag is found, insert the CSS at the start of the output
      if !page.output.match(%r{<head>(.*?)</head>}m)
        Jekyll.logger.debug 'GFMA:', "No <head> tag found in '#{page.path}', inserting CSS at the beginning of the page."
        page.output = "<head><style>#{CSSminify.compress(css)}</style></head>" + page.output
      end
    end
  end
=end
end