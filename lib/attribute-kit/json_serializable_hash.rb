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
  module JSONSerializableHash
    def to_json(opts = {})
      JSON.generate(self, opts)
    end

    def from_json(json, opts = {})
      defaults = {
          :symbolize_keys => true
      }
      opts.merge!(defaults){ |key, param, default| param }
      self.replace(JSON.parse(json, opts))
    end

    def get_json(key, opts = {})
      JSON.generate({key => self[key]}, opts)
    end

    def store_json(json, opts = {})
      defaults = {
          :symbolize_keys => true
      }
      opts.merge!(defaults){ |key, param, default| param }
      self.update(JSON.parse(json, opts))
    end
  end
end
