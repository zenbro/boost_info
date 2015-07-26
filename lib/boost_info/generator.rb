module BoostInfo
  class Generator
    def initialize(root_node, opts={})
      @root_node = root_node
      @opts = opts
      @opts[:indent] ||= 4
    end

    def to_hash
      build_hash(@root_node)
    end

    def to_info
      build_info(@root_node, 0).join("\n") + "\n"
    end

    private

    def build_hash(parent_node)
      hash = {}
      parent_node.childrens.each do |node|
        key = @opts[:symbolize_keys] ? node.key.to_sym : node.key
        if node.childrens
          hash[key] = build_hash(node)
        else
          hash[key] = node.value
        end
      end
      hash
    end

    def build_info(parent_node, level)
      lines = []
      last_node_index = parent_node.childrens.size - 1
      parent_node.childrens.each_with_index do |node,index|
        if node.childrens.nil?
          value = wrap_in_quotes(node.value)
          lines << add_indent("#{node.key} #{value}", level)
        elsif node.childrens.any?
          lines << add_indent("#{node.key} {", level)
          nested_lines = build_info(node, level + 1)
          lines.concat(nested_lines)
        elsif node.childrens.empty?
          lines << add_indent("#{node.key} { }", level)
        end
        if level > 0 && index == last_node_index
          lines << add_indent("}", level - 1)
        end
      end
      lines
    end

    def add_indent(string, level)
      indent = @opts[:indent] * level
      "#{' ' * indent if indent > 0}#{string}"
    end

    def wrap_in_quotes(value)
      string = value.to_s
      string =~ /[\s\/:;.,{}]/ ? '"' + string + '"' : string
    end
  end
end
