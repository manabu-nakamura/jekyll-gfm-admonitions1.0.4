module Jekyll
  module Converters
    class Markdown
      class RedcarpetParser
        alias :old_convert :convert
        def convert(content)
          content.gsub! /(^|\s)(--\w+)/ do
            "#{$1}<small>#{$2}</small>"
          end
          old_convert(content)
        end
      end
    end
  end
end
