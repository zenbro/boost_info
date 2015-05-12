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
          @result << add_indent(k, level)
          if v.is_a?(Hash)
            @result << " {\n"
            iterate_hash(v, level + 1)
          else
            v = v.to_s
            # Wrap "values with spaces, /, :, ., or ,"
            v = %["#{ v }"] if v[/[\s\/:.,]/]
            @result << ' ' + v + "\n"
            @result << add_indent("}\n", level - 1) if k == hash.keys.last
          end
        end
      end

      def add_indent(string, level)
        indent = @opts[:indent] * level
        "#{ ' ' * indent if indent > 0}#{string}"
      end
  end
end
