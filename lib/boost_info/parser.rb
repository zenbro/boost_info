require 'boost_info/node'

module BoostInfo
  class ParseError < StandardError; end

  class Parser
    attr_accessor :nodes

    # Boost info tokens
    @@tokens = '{}'
    @@open_token = '{'
    @@close_token = '}'

    def initialize(source, opts={})
      unless source.is_a?(String)
        raise TypeError, "no implicit conversion of #{source.class} into String"
      end

      # Initialize instance variables
      @nodes = []
      @level = 0
      @source = source
      @tokens = []
      @opts = opts
      @opts[:symbolize_keys] ||= false

      # without empty lines and comments
      tokenize! { |token| @tokens << token }
    end

    def parse
      # Parse source
      opens = @source.count(@@open_token)
      closes = @source.count(@@close_token)
      if opens != closes
        raise BoostInfo::ParseError, "open [#{opens}] and close tokens [#{closes}] does not match..."
      end
      nodes = {}
      @tokens.each do |token|
        if @@open_token == token
          @level += 1
        elsif @@close_token == token
          @level -= 1
        else
          list = token.split
          if list.size > 2
            val = list[1..-1].join(" ")
          else
            val = list[1]
          end
          val = val.gsub(/\A["]+|["]+\z/, "") if val
          node = Node.new(@level, list[0], val)
          nodes[@level] = node
          if @level == 0
            @nodes << node
          else
            nodes[@level] = node unless nodes.has_key?(@level)
            nodes[@level-1].add_child(node)
          end
        end
      end
      self
    end

    def find(name)
      # Recursive node search by name
      result_node = nil
      @nodes.each do |node|
        result_node = node.find(name)
        break if result_node
      end
      result_node
    end

    def [](offset)
      # Get elements by key
      find(offset)
    end

    def print_node(node)
      # Print node with children
      puts node
      node.children.each { |child| print_node(child) }
      puts "#{'| '*node.level}#{node.level} #{node.name} close" if node.has_children?
    end

    def print_tree
      # Print parsed tree
      @nodes.each { |node| print_node(node) }
    end

    def child_source(node)
      result = '  '*node.level + node.name + (node.value ? " #{ node.value }" : '')
      if node.has_children?
        result += " {\n"
        node.children.each { |child| result += self.child_source(child) }
        result += '  '*node.level + "}\n"
      else
        result += "\n"
      end
      result
    end

    def to_s
      self.to_h.to_info
    end

    def to_h
      result = {}
      @nodes.each { |n| result.merge!(n.to_h(@opts[:symbolize_keys])) }
      result
    end

    private

      def tokenize!
        # tokenize boost info format
        lines = []
        @source.split("\n").each do |line|
          lines << line.split(';')[0].strip unless line.strip.empty? || line.strip[0] == ';'
        end
        lines.each do |line|
          token = ''
          line.each_char do |char|
            if '{}'.include?(char)
              token = token.strip
              yield token unless token.empty?
              yield char
              token = ''
            else
              token += char
            end
          end
          yield token.strip unless token.empty?
        end
      end
  end
end
