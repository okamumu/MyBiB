require 'yaml'

module LDBib

  class Doc
    def initialize(filters, keys)
      @filters = filters
      @global = Node.new(@filters, keys)
      @keys = keys
    end

    def global
      @global
    end

    def to_ruby
      YAML.load(to_yaml)
    end
  end

  class DocArray < Doc
    def initialize(filters, keys)
      super(filters, keys)
      @docarray = Array.new
    end

    def addNewNode
      tmp = Node.new(@filters, @keys)
      @docarray << tmp
      tmp
    end

    def to_yaml(symbol = true)
      buf = "---\n"
      @docarray.each do |value|
        buf << "-\n"
        buf << @global.to_yaml(symbol)
        buf << value.to_yaml(symbol)
      end
      buf
    end
  end

  class DocHash < Doc
    def initialize(filters, keys)
      super(filters, keys)
      @dochash = Hash.new
    end

    def addNewNode(key)
      tmp = Node.new(@filters, @keys)
      if @dochash.has_key?(key)
        raise "The key #{key} has already used."
      else
        @dochash[key] = tmp
      end
      tmp
    end

    def to_yaml(symbol = true)
      buf = "---\n"
      @dochash.each do |key, value|
        if symbol
          buf << ":#{key}:\n"
        else
          buf << "#{key}:\n"
        end
        buf << @global.to_yaml(symbol)
        buf << value.to_yaml(symbol)
      end
      buf
    end
  end

  class Node
    def initialize(filters, keys)
      @filters = filters
      @val = Hash.new
      @keys = keys
    end

    def add(key, value)
      if @keys.include?(key)
        @val[key] = value
      else
        raise "#{key} does not exist in the key list."
      end
    end

    def append(key, value)
      if @keys.include?(key)
        @val[key] << " " + value
      else
        raise "#{key} does not exist in the key list."
      end
    end

    def to_yaml(symbol = true)
      buf = ''
      @val.each do |key, value|
        if @filters[key] != nil
          if symbol
            buf << "    :#{key}: #{@filters[key].call(value)}\n"
          else
            buf << "    #{key}: #{@filters[key].call(value)}\n"
          end
        else
          if symbol
            buf << "    :#{key}: #{value}\n"
          else
            buf << "    #{key}: #{value}\n"
          end
        end
      end
      buf
    end
  end

  # def unsymbolize_keys(hash)
  #   hash.map{|x|
  #     x.map{|k,v| [k.to_s, v] }.to_h
  #   }
  # end

  def load(str, keys = Keys, filters = Filters, datatype = :hash)
    case datatype
    when :array
      document = DocArray.new(filters, keys)
    when :hash
      document = DocHash.new(filters, keys)
    else
    end
    current = nil
    previous_key = nil
    str.each_line do |line|
      line.chop!
      case line
      when /^#/, /^\s*$/
        current = nil
        previous_key = nil
      when /^[A-Za-z_]/
        m = line.match(/^([a-zA-Z_]+)\s*:\s*(.*)\s*$/)
        previous_key = m[1].to_sym
        if current == nil
          case datatype
          when :array
            current = document.addNewNode
          when :hash
            current = document.addNewNode(m[2].to_sym)
          else
          end
        end
        current.add(previous_key, m[2])
      when /^@[A-Za-z_]/
        m = line.match(/^@([a-zA-Z_]+)\s*:\s*(.*)\s*$/)
        previous_key = m[1].to_sym
        current = nil
        document.global.add(previous_key, m[2])
      when /^\s/
        if previous_key != nil
          m = line.match(/^\s+(.*)\s*$/)
          if current != nil
            current.append(previous_key, m[1])
          else
            document.global.append(previous_key, m[1])
          end
        end
      else
        #      puts "Not match #{line}."
      end
    end
    document
  end

  def load_file(fn, keys = Keys, filters = Filters, datatype = :hash)
      File.open(fn) {|f|
        load(f.read, keys, filters, datatype)
      }
  end
  ### filters

  class Filter
    def filter(value)
      value
    end

    def call(value)
      filter(value)
    end
  end

  class ArrayFilter < Filter
    def call(value)
      "[#{super(value)}]"
    end
  end

  class SymbolFilter < Filter
    def call(value)
      ":#{super(value)}"
    end
  end

  class NameFilter < ArrayFilter
    def filter(value)
      value.gsub(/\s+and\s+/, ", ")
    end
  end

  class DateFilter < ArrayFilter
    def filter(value)
      value.gsub(/\//, ",")
    end
  end

  class PagesFilter < ArrayFilter
    def filter(value)
      value.gsub(/[-]+/, ",")
    end
  end

  Keys = [
    :type,
    :citekey,
    :author,
    :title,
    :pages,
    :journal,
    :volume,
    :number,
    :issue,
    :date,
    :publisher,
    :editor,
    :address,
    :booktitle,
    :booksubtitle,
    :conference,
    :doi,
    :url,
    :isbn,
    :eauthor,
    :etitle,
    :ejournal
  ]

  Filters = Hash.new
  Filters[:author] = NameFilter.new
  Filters[:eauthor] = NameFilter.new
  Filters[:editor] = NameFilter.new
  Filters[:citekey] = SymbolFilter.new
  Filters[:type] = SymbolFilter.new
  Filters[:volume] = ArrayFilter.new
  Filters[:pages] = PagesFilter.new
  Filters[:date] = DateFilter.new

end
