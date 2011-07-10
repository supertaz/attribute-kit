class AttributeHash < DelegateClass(Hash)
  def initialize
    super({})
    @dirty_keys = Array.new
    @internal_hash_value = self.hash
  end

  def []=(k,v)
    old_v = __getobj__[k]
    if old_v != v
      @dirty_keys << k
      __getobj__[k] = v
    else
      v
    end
  end

  def dirty?
    (@dirty_attributes.length > 0) || (self.hash != @internal_hash_value)
  end

  def dirty_keys
    @dirty_keys.uniq!
    @dirty_keys
  end

  def clean_attributes(&block)
    @dirty_keys.uniq!
    was_dirty = (@dirty_keys.length > 0)

    if was_dirty
      dirty_attrs = Hash.new

      while @dirty_keys.length > 0 do
        k = @dirty_keys.shift
        dirty_attrs[k] = __getobj__[k]
      end

      block.call(dirty_attrs)
      @internal_hash_value = self.hash
    end
  end
end

class DirtyKeysPresentException < Exception
end
