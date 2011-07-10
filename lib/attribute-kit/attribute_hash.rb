# A group of classes and other tools that are designed to make handling of attributes and dealing with changes to
# groups of attributes easy and convenient.  This is particularly useful if you intend to build, extend, or even
# simply wish to avoid using someone else's ORM or DRM.
#
# The original intent of this library was to make it easier to store and track changes to attributes on a model that
# was not managed by an ORM, yet needed to be selectively synchronized between a client, server, and data store.  From
# those humble beginnings, this optimized library was created.
#
# Author::      Jonathan Mischo (mailto: jon.mischo@gmail.com)
# Copyright::   Copyright (c) 2011 Jonathan Mischo
# License::     Distributed under the MIT license (see LICENSE.txt, distributed with the original source code)

module AttributeKit

  # AttributeHash inherits from and extends Hash, to provide tracking of attribute status (changed/deleted keys).
  class AttributeHash < Hash

    def initialize(*args)
      super(*args)
      @dirty_keys = []
      @deleted_keys = []
    end

    def []=(k,v)
      if self[k].eql? v
        v
      else
        @dirty_keys << k
        super
      end
    end

    alias_method :store, :[]=

    def delete(k)
      @deleted_keys << k
      @dirty_keys.delete(k)
      super
    end

    %w{delete_if keep_if reject! select!}.each do |func_name|
      define_method(func_name.to_sym) { |&block|
        unless block.nil?
          keys = self.keys
          r = super(&block)
          @deleted_keys += keys - self.keys
          r
        else
          super()
        end
      }
    end

    def replace(other_hash)
      old_keys = self.keys
      r = super
      new_keys = self.keys
      @dirty_keys = new_keys
      @deleted_keys += (old_keys - new_keys)
      r
    end

    def merge!(other_hash, &block)
      old_keys = self.keys
      r = super
      @dirty_keys += self.keys - old_keys
      r
    end

    alias_method :update, :merge!

    def shift
      old_keys = self.keys
      r = super
      @deleted_keys += old_keys - self.keys
      r
    end

    def clear
      @deleted_keys += self.keys
      @dirty_keys.clear
      super
    end

    def dirty?
      !(@dirty_keys.empty? && @deleted_keys.empty?)
    end

    # This method returns the set of keys that have been modified since the AttributeHash was last marked clean.
    def dirty_keys
      @dirty_keys.uniq!
      @dirty_keys + self.deleted_keys
    end

    def deleted_keys
      @deleted_keys.uniq!
      @deleted_keys
    end

    def clean_attributes(&block)
      if !@dirty_keys.empty?
        dirty_attrs = {}
        @dirty_keys.uniq!

        while @dirty_keys.length > 0 do
          key = @dirty_keys.shift
          dirty_attrs[key] = [:changed, self[key]]
        end

        while @deleted_keys.length > 0 do
          key = @deleted_keys.shift
          dirty_attrs[key] = [:deleted, nil]
        end

        block.call(dirty_attrs)
      end
    end

    def method_missing(method, *args, &block)
      method_name = method.to_s
      case method_name
        when /(.*)_dirty?/
          return @dirty_keys.include?($1) if self.has_key?($1)
          return @dirty_keys.include?($1.to_sym) if self.has_key?($1.to_sym)
          @deleted_keys.include?($1) || @deleted_keys.include?($1.to_sym)
        when /(.*)_deleted?/
          @deleted_keys.include?($1) || @deleted_keys.include?($1.to_sym)
        else
          if self.class.superclass.instance_methods.include?('method_missing')
            super(method, *args, &block)
          else
            raise NoMethodError.new("undefined method '#{method_name}' for #{self}")
          end
      end
    end
  end
end
