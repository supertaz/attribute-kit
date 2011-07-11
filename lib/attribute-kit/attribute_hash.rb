# A group of classes and other tools that are designed to make handling of attributes and dealing with changes to
# groups of attributes easy and convenient.  This is particularly useful if you intend to build, extend, or even
# simply wish to avoid using someone else's ORM or DRM.
#
# The original intent of this library was to make it easier to store and track changes to attributes on a model that
# was not managed by an ORM, yet needed to be selectively synchronized between a client, server, and data store.  From
# those humble beginnings, this optimized library was created.
#
# @author Jonathan Mischo
# @note Copyright (c) 2011 Jonathan Mischo
# @note Distributed under the MIT license (see LICENSE.txt, distributed with the original source code)

module AttributeKit

  # AttributeHash inherits from and extends Hash, to provide tracking of attribute status (changed/deleted keys).
  class AttributeHash < Hash

    # Creates a new instance, using identical syntax to Hash
    # @see Hash#new
    def initialize(*args)
      super(*args)
      @dirty_keys = []
      @deleted_keys = []
    end

    # Assigns a value to a key
    # @see Hash#[]=
    def []=(k,v)
      if self[k].eql? v
        v
      else
        @dirty_keys << k
        super
      end
    end

    # @method store(key, value)
    # Assigns a value to a key
    # @see Hash#store
    alias_method :store, :[]=

    # Delete a key
    # @see Hash#delete
    def delete(k)
      @deleted_keys << k
      @dirty_keys.delete(k)
      super
    end

    # @method delete_if {|key, value|}
    # Delete keys matching an expression in the block
    # @see Hash#delete_if

    # @method keep_if {|key, value|}
    # Delete keys not matching an expression in the block
    # @see Hash#keep_if

    # @method reject! {|key, value|}
    # Delete keys matching an expression in the block and return nil if nothing is changed
    # @see Hash#reject!

    # @method select! {|key, value|}
    # Delete keys not matching an expression in the block and return nil if nothing is changed
    # @see Hash#select!

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

    # Replace the contents of this object with the contents of the supplied hash
    # @see Hash#replace
    def replace(other_hash)
      old_keys = self.keys
      r = super
      new_keys = self.keys
      @dirty_keys = new_keys
      @deleted_keys += (old_keys - new_keys)
      r
    end

    # Combine the contents of this object with the contents of the supplied hash, calling an optional supplied block to
    # determine what value is used when there are duplicate keys.  Without the block, values from the supplied hash will
    # be used in the case of duplicate keys
    # @see Hash#merge!
    def merge!(other_hash, &block)
      old_keys = self.keys
      r = super
      @dirty_keys += self.keys - old_keys
      r
    end

    # @method update(other_hash, &block)
    # @see #merge!
    alias_method :update, :merge!

    # Return a key-value pair from the contents of the object and delete them.
    # @see Hash#shift
    def shift
      old_keys = self.keys
      r = super
      @deleted_keys += old_keys - self.keys
      r
    end

    # Clear all contents of the object.
    # @see Hash#clear
    def clear
      @deleted_keys += self.keys
      @dirty_keys.clear
      super
    end

    # Check whether the contents of the object have changed since the last time clean_attributes was run.
    # @return [Boolean] value indicating whether or not key-value pairs have been added, changed, or deleted
    def dirty?
      !(@dirty_keys.empty? && @deleted_keys.empty?)
    end

    # Returns the set of keys that have been modified since the AttributeHash was last marked clean.
    # @return [Array] all of the changed keys
    def dirty_keys
      @dirty_keys.uniq!
      @dirty_keys + self.deleted_keys
    end

    # Returns the set of keys that have been deleted since the AttributeHash was last marked clean.
    # @return [Array] all of the deleted keys
    def deleted_keys
      @deleted_keys.uniq!
      @deleted_keys
    end

    # Calls a block with a hash of all keys, actions (:changed or :deleted), and current values (if :changed) of keys
    # that have changed since the object was last marked clean.  Marks the object as clean when it compiles
    # the list of keys that have been modified.
    # @param [Block] block to execute with hash of modified keys, actions, and values
    def clean_attributes(&block)
      if !@dirty_keys.empty?
        dirty_attrs = {}
        @dirty_keys.uniq!
        dirty = @dirty_keys.dup
        @dirty_keys.clear
        deleted = @deleted_keys.dup
        @deleted_keys.clear

        while dirty.length > 0 do
          key = dirty.shift
          dirty_attrs[key] = [:changed, self[key]]
        end

        while deleted.length > 0 do
          key = deleted.shift
          dirty_attrs[key] = [:deleted, nil]
        end

        block.call(dirty_attrs)
      end
    end

    # @method <key>_dirty?
    # Check whether a particular key is dirty
    # @return [Boolean] value indicating key-value pair state
    # @note Uses method_missing to implement the check

    # @method <key>_deleted?
    # Check whether a particular key has been deleted
    # @return [Boolean] value indicating key-value pair state
    # @note Uses method_missing to implement the check
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
