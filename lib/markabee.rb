module Markabee
  SELF_CLOSING_TAGS = [ :base, :meta, :link, :hr, :br, :param,
                        :img, :area, :input, :col, :frame ]

  class Builder
    attr_accessor :tag, :attributes, :content

    def initialize tag=nil, attributes={}, &block
      @tag = tag
      @attributes = { :classes => [] }.merge attributes
      @content = []
      @in_block = false
      insert &block
    end

    def method_missing name, args={}, &block
      return add_child name, args, &block if @in_block

      @attributes[:classes] << name

      if args.respond_to? :to_hash
        @attributes[:classes] << args.delete(:class) if args.has_key? :class

        @attributes.merge! args

        insert(&block) if block_given?
      else
        @content << args if args.is_a? String
      end

      self
    end

    def add_child(name, attrs_or_content, &block)
      ele = if attrs_or_content.respond_to? :to_hash
              Builder.new(name, attrs_or_content.to_hash, &block)
            else
              Builder.new(name, {}) { attrs_or_content }
            end

      @content << ele
      ele
    end

    # override Kernel.p
    def p attrs={}, &block
      add_child :p, attrs, &block
    end

    def insert &content
      return self unless block_given?

      @in_block = true
      body = instance_eval &content
      @in_block = false

      @content << body if body.is_a? String

      self
    end

    def html5
      @content << "<!DOCTYPE html>"
    end

    def to_s
      return @content.map(&:to_s).join unless @tag

      attrs = @attributes.map do |name, val|
        if name == :classes
          " class=\"#{val.join ' '}\"" unless val.empty?
        else
          " #{name}=\"#{val}\""
        end
      end.join

      return "<#{@tag.to_s + attrs} />" if SELF_CLOSING_TAGS.include? @tag

      "<#{@tag.to_s + attrs}>#{@content.map(&:to_s).join}</#{@tag}>"
    end
  end
end
