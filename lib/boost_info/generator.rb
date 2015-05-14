require 'boost_info/node'

module BoostInfo
  class Generator
    def initialize(hash, opts={})
      raise TypeError unless hash.is_a?(Hash)
      @hash = hash
      @opts = opts
      @opts[:indent] ||= 4
    end

    def generate
      @result = ''
      level = 0
      iterate_hash(@hash, level)
      @result
    end

    private

      def iterate_hash(hash, level)
        hash.each do |k,v|
          k = k.to_s
          if v.is_a?(Hash)
            # Wrap hash in curly braces
            @result << add_indent("#{ k } {\n", level)
            iterate_hash(v, level + 1)
            @result << add_indent("}\n", level)
          else
            v = v.to_s
            # Wrap spaces and special symbols in double quotes
            v = %["#{ v }"] if v[/[\s\/:;.,]/]
            @result << add_indent("#{ k } #{ v }\n", level)
          end
        end
      end

      def add_indent(string, level)
        indent = @opts[:indent] * level
        "#{ ' ' * indent if indent > 0}#{string}"
      end
  end
end
