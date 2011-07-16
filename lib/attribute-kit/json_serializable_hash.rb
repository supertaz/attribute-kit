begin
  require 'yajl/json_gem'
rescue LoadError
  begin
    require 'json'
  rescue LoadError
    require 'json_pure'
  end
end

module AttributeKit

  # JSONSerializableHash adds a set of methods to manage serialization and deserialization of hashes and Hash decendants
  # in a consistent manner.  By default, the methods symbolize the keys when they are deserialized, which greatly
  # improves performance and also provides consistency in how keys appear both in JSON and in the hash.
  module JSONSerializableHash

    # Serializes the entire hash contents into a JSON string.
    # @param [Hash] opts A hash of options to be passed to the JSON generator, empty by default
    # @return [String] A JSON encoded string describing the contents of the hash
    def to_json(opts = {})
      JSON.generate(self, opts)
    end

    # Deserializes hash contents from a JSON string, replacing the contents of the hash if they already exist
    # @param [String] json A JSON formatted string to be parsed and assigned as the contents of the hash
    # @param [Hash] opts A hash of options to be passed to the JSON generator, :symbolize_keys => true is set by default
    # @return [Hash] The new contents of the hash
    def from_json(json, opts = {})
      defaults = {
          :symbolize_keys => true
      }
      opts.merge!(defaults){ |key, param, default| param }
      self.replace(JSON.parse(json, opts))
    end

    # Serializes a single key-value pair from the hash contents into a JSON string.
    # @param [Symbol] key The key for the key-value pair to retrieve and encode
    # @param [Hash] opts A hash of options to be passed to the JSON generator, empty by default
    # @return [String] A JSON encoded string describing the key-value pair
    def get_json(key, opts = {})
      JSON.generate({key => self[key]}, opts)
    end

    # Deserializes hash contents from a JSON string, merging the contents with any contents of the hash that already exist
    # @param [String] json A JSON formatted string to be parsed and update the contents of the hash with
    # @param [Hash] opts A hash of options to be passed to the JSON generator, :symbolize_keys => true is set by default
    # @return [Hash] The new contents of the hash
    def store_json(json, opts = {})
      defaults = {
          :symbolize_keys => true
      }
      opts.merge!(defaults){ |key, param, default| param }
      self.update(JSON.parse(json, opts))
    end
  end
end
