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
  #
  # @example Basic usage
  #   attributes = AttributeKit::AttributeHash.new              #=> {}
  #
  #   attributes.empty?                                         #=> true
  #   attributes.dirty?                                         #=> false
  #   attributes[:foo] = 'bar'                                  #=> 'bar'
  #   attributes.dirty?                                         #=> true
  #   attributes.dirty_keys                                     #=> [:foo]
  #   attributes                                                #=> {:foo=>"bar"}
  #
  #   attributes[:bar] = 5                                      #=> 5
  #   attributes                                                #=> {:foo=>"bar", :bar=>5}
  #   attributes.dirty_keys                                     #=> [:foo, :bar]
  #   attributes.deleted_keys                                   #=> []
  #
  #   attributes.delete(:foo)                                   #=> "bar"
  #   attributes.dirty_keys                                     #=> [:bar, :foo]
  #   attributes.deleted_keys                                   #=> [:foo]
  #
  #   attributes.clean_attributes { |dirty_attrs|               # Deleted: foo    Nil value: true
  #     dirty_attrs.each_pair do |k,v|                          # Changed: bar    New value: 5
  #       case v[0]
  #         when :changed                                       #=> {:foo=>[:deleted, nil], :bar=>[:changed, 5]}
  #           puts "Changed: #{k}    New value: #{v[1]}"
  #         when :deleted                                       # NOTE: The lack of a return value in this block
  #           puts "Deleted: #{k}    Nil value: #{v[1].nil?}"   #       means that dirty_attrs was returned by both
  #       end                                                   #       the block and the method itself.  You may
  #     end                                                     #       want to write a block to return true if it
  #   }                                                         #       succeeds, and the dirty_attrs hash if it
  #                                                             #       fails, so you can pass the hash to a
  #                                                             #       method that can retry later.
  #
  class AttributeHash < Hash

    # @visibility private
    def self.cond_deletion_method(method_name)
      define_method(method_name) { |&block|
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

    private_class_method :cond_deletion_method

    # Creates a new instance, using identical syntax to Hash
    # @return [AttributeHash] new instance
    # @see Hash#new
    def initialize(*args)
      super(*args)
      @dirty_keys = []
      @deleted_keys = []
    end

    # Assigns a value to a key
    # @param [Object] k key of key-value pair to insert or change in instance
    # @param [Object] v value of key-value pair to insert or change in instance
    # @return [Object] value of key-value pair inserted
    # @see Hash#[]=
    def []=(k,v)
      if self[k].eql? v
        v
      else
        @dirty_keys << k
        super
      end
    end

    alias_method :store, :[]=

    # Delete a key-value pair
    # @param [Object] key key of key-value pair to delete from instance
    # @return [Object] value of key-value pair deleted
    # @see Hash#delete
    def delete(k)
      @deleted_keys << k
      @dirty_keys.delete(k)
      super
    end

    # @method reject!
    # Delete keys matching an expression in the provided block
    # @return [AttributeHash] if changes are made
    # @return [Nil] if no changes are made
    # @yield [key, value] block is executed for every key-value pair stored in the instance
    # @yieldparam [Object] key the key from the key-value pair being evaluated
    # @yieldparam [Object] value the value from the key-value pair being evaluated
    # @yieldreturn [Boolean] whether or not to delete a particular stored key-value pair from the instance
    # @see Hash#reject!
    cond_deletion_method(:reject!)

    # @method select!
    # Delete keys not matching an expression in the provided block
    # @return [AttributeHash] if changes are made
    # @return [Nil] if no changes are made
    # @yield [key, value] block is executed for every key-value pair stored in the instance
    # @yieldparam [Object] key the key from the key-value pair being evaluated
    # @yieldparam [Object] value the value from the key-value pair being evaluated
    # @yieldreturn [Boolean] whether or not to keep a particular stored key-value pair in the instance
    # @see Hash#select!
    cond_deletion_method(:select!)

    # @method keep_if
    # Delete keys not matching an expression in the provided block
    # @return [AttributeHash] self with changes applied
    # @yield [key, value] block is executed for every key-value pair stored in the instance
    # @yieldparam [Object] key the key from the key-value pair being evaluated
    # @yieldparam [Object] value the value from the key-value pair being evaluated
    # @yieldreturn [Boolean] whether or not to keep a particular stored key-value pair in the instance
    # @see Hash#keep_if
    cond_deletion_method(:keep_if)

    # @method delete_if
    # Delete keys matching an expression in the provided block
    # @return [AttributeHash] self with changes applied
    # @yield [key, value] block is executed for every key-value pair stored in the instance
    # @yieldparam [Object] key the key from the key-value pair being evaluated
    # @yieldparam [Object] value the value from the key-value pair being evaluated
    # @yieldreturn [Boolean] whether or not to delete a particular stored key-value pair from the instance
    # @see Hash#delete_if
    cond_deletion_method(:delete_if)

    # Replace the contents of this object with the contents of the supplied hash
    # @param [Hash] other_hash hash of values to replace instance contents with
    # @return [AttributeHash] self with changes applied
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
    # @param [Hash] other_hash hash of values to merge in to the instance
    # @yield [key, oldval, newval] block is executed for every duplicate key between the instance and other_hash
    # @yieldparam [Object] key the key being evaluated
    # @yieldparam [Object] oldval the value from the value from the instance
    # @yieldparam [Object] newval the value from the value from other_hash
    # @yieldreturn [Object] the value to store for the key in question
    # @return [AttributeHash] self with changes applied
    # @see Hash#merge!
    def merge!(other_hash, &block)
      old_keys = self.keys
      overlapping_keys = old_keys.dup.keep_if {|v| other_hash.keys.include?(v)}
      r = super
      if block.nil?
        @dirty_keys += (self.keys - old_keys) + overlapping_keys
      else
        new_values = other_hash.keep_if {|k,v| overlapping_keys.include?(k)}
        @dirty_keys += (self.keys - old_keys) + (new_values.keep_if {|k,v| !self[k].eql?(v) }).keys
      end
      r
    end

    alias_method :update, :merge!

    # Returns a key-value pair from the instance and deletes it.
    # @return [Array] key-value pair
    # @see Hash#shift
    def shift
      (k,v) = super
      @deleted_keys << k
      [k,v]
    end

    # Clear all contents of the object and mark it as dirty.  An array of all removed keys is available via #deleted_keys.
    # @return [AttributeHash] an empty AttributeHash
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
    # @yield [dirty_attrs] block is executed once, with a hash of dirty attributes
    # @yieldparam [Hash] dirty_attrs the hash of changed/deleted attributes with the modified key as the key and a value
    #   of an array in the format: [ACTION, VALUE] where ACTION is either :changed or :deleted, and VALUE is either the
    #   new value or nil if the attribute is deleted.  A nil value does NOT mean the attribute is deleted if the ACTION
    #   is :changed, it means the value was actually set to nil
    # @yieldreturn [Object] any value the block returns bubbles up, otherwise
    # @return [Object] the return value of the block is returned
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

    # @overload KEY_dirty?()
    #   Check whether a particular key is dirty - KEY is a string representation of the key name for the key-value pair being queried
    #   @note There can be conflicts if you have multiple keys that are similar, i.e. :blue and 'blue', so only use this
    #     when you can guarantee homogenous keys and are using either strings or symbols for the key (the only cases where
    #     it will work)
    #   @return [Boolean] value indicating key-value pair state
    #   @note Uses method_missing to implement the check
    # @overload KEY_deleted?()
    #   Check whether a particular key has been deleted - KEY is a string representation of the key name for the key-value pair being queried
    #   @note There can be conflicts if you have multiple keys that are similar, i.e. :blue and 'blue', so only use this
    #     when you can guarantee homogenous keys and are using either strings or symbols for the key (the only cases where
    #     it will work)
    #   @return [Boolean] value indicating key-value pair state
    #   @note Uses method_missing to implement the check

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
          if self.class.superclass.instance_methods.map(&:to_sym).include?(:method_mising)
            super(method, *args, &block)
          else
            raise NoMethodError.new("undefined method '#{method_name}' for #{self}")
          end
      end
    end

  end
end
