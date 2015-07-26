require 'boost_info/node'

module BoostInfo
  class Parser
    class ParseError < StandardError; end

    attr_accessor :root_node

    OPEN_TOKEN = '{'
    CLOSE_TOKEN ='}'

    def initialize(source, opts={})
      @source = source
      @opts = opts
      @opts[:symbolize_keys] ||= false
      @root_node = Node.new(root: true)
    end

    def self.from_info(source, opts={})
      unless source.is_a?(String)
        fail TypeError, "no implicit conversion of #{source.class} into String"
      end
      new(source, opts).parse_info
    end

    def self.from_hash(source, opts={})
      unless source.is_a?(Hash)
        fail TypeError, "no implicit conversion of #{source.class} into Hash"
      end
      new(source, opts).parse_hash
    end

    def parse_info
      lines = process_source(@source)
      traverse_info(@root_node, lines, -1)

      @root_node
    end

    def parse_hash
      traverse_hash(@source, @root_node)

      @root_node
    end

    private

    def process_source(source)
      lines = []
      source.each_line do |line|
        new_line = line.sub(/;.+[^"']$/, '').strip # remove comments
        next if new_line.empty?
        # include file
        if new_line.match(/#include\s+(\S+)/)
          file_path = strip_quotes(Regexp.last_match(1))
          file = File.open(file_path)
          lines_to_include = process_source(file)
          lines.concat(lines_to_include)
        # process inline section
        elsif new_line.match(/#{OPEN_TOKEN}.*#{CLOSE_TOKEN}/)
          splitted_lines = line.sub('{', "{\n").sub('}', "\n}").lines
            .map(&:strip)
            .reject(&:empty?)
          lines.concat(splitted_lines)
        #just add the line
        else
          lines << new_line
        end
      end

      open_tokens = lines.count { |line| line.end_with?(OPEN_TOKEN) }
      close_tokens = lines.count { |line| line.end_with?(CLOSE_TOKEN) }
      if open_tokens != close_tokens
        fail ParseError, "open [#{open_tokens}] and close tokens [#{close_tokens}] does not match..."
      end
      lines
    end

    def traverse_info(parent_node, lines, index_start)
      index_end = lines.size - 1
      lines.each_with_index do |line,index|
        next if index <= index_start

        index_end = index

        key, value = extract_key_and_value(line)
        node = Node.new(key: key, value: value)
        parent_node.insert_node(node) if key

        case line
        when /#{OPEN_TOKEN}/
          index_start = traverse_info(node, lines, index)
        when /#{CLOSE_TOKEN}/
          parent_node.childrens ||= []
          break
        end
      end
      index_end
    end

    def traverse_hash(hash, parent_node)
      hash.each do |k,v|
        node = parent_node.insert(k, v)
        if v.is_a?(Hash)
          node.childrens = []
          traverse_hash(v, node)
        end
      end
      parent_node
    end

    def extract_key_and_value(string)
      key = nil
      value = nil

      tokens = string.split(/\s+/)
      raw_key = tokens.shift.sub('}', '').strip
      key = raw_key unless raw_key.empty?

      tokens.pop if tokens.last == OPEN_TOKEN
      value = strip_quotes(tokens.join(' ')) unless tokens.empty?
      value = value.to_i if value.to_s =~ /^\d+$/
      [key, value]
    end

    def strip_quotes(string)
      string.gsub(/^["']+|["']+$/, '')
    end
  end
end
