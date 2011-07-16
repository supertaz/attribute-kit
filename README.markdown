# attribute-kit

Tools for attribute tracking like Hashes with dirty tracking and events, for building hybrid models and generally going beyond what's provided by your local ORM/DRM, while allowing you to expand what you can do with them, live without them, or roll your own

## Rationale

ORM and DRM frameworks implement many of the same concepts that this kit makes available, but they don't generally expose them
as smaller pieces of functionality that you can consume and mix in as you please.  It is also difficult to get more ORMs to
'play nice' with columns that are really schemaless hashes, because they just aren't meant to handle such things.  While DRMs
are generally designed to work with schemaless data, there are times when you need to have both behaviors.

The idea behind building AttributeKit was to make these concepts available in an ad-hoc format, so that classes could either
inherit or mix in the behaviors that they want and/or need, without the overhead of the pieces they don't want or need.  This
all stemmed from a side project that had a need for exactly that...ORM/DRM-like behavior, without the extra weight of actually
using one of the ORMs or DRMs on the market and then extending them to handle both types of data, in two separate data stores.

## Basic usage

    attributes = AttributeKit::AttributeHash.new              #=> {}

    attributes.empty?                                         #=> true
    attributes.dirty?                                         #=> false
    attributes[:foo] = 'bar'                                  #=> 'bar'
    attributes.dirty?                                         #=> true
    attributes.dirty_keys                                     #=> [:foo]
    attributes                                                #=> {:foo=>"bar"}

    attributes[:bar] = 5                                      #=> 5
    attributes                                                #=> {:foo=>"bar", :bar=>5}
    attributes.dirty_keys                                     #=> [:foo, :bar]
    attributes.deleted_keys                                   #=> []

    attributes.delete(:foo)                                   #=> "bar"
    attributes.dirty_keys                                     #=> [:bar, :foo]
    attributes.deleted_keys                                   #=> [:foo]

    attributes.clean_attributes { |dirty_attrs|               # Deleted: foo    Nil value: true
      dirty_attrs.each_pair do |k,v|                          # Changed: bar    New value: 5
        case v[0]
          when :changed                                       #=> {:foo=>[:deleted, nil], :bar=>[:changed, 5]}
            puts "Changed: #{k}    New value: #{v[1]}"
          when :deleted                                       # NOTE: The lack of a return value in this block
            puts "Deleted: #{k}    Nil value: #{v[1].nil?}"   #       means that dirty_attrs was returned by both
        end                                                   #       the block and the method itself.  You may
      end                                                     #       want to write a block to return true if it
    }                                                         #       succeeds, and the dirty_attrs hash if it
                                                              #       fails, so you can pass the hash to a
                                                              #       method that can retry later.

## Serializing and deserializing a Hash with JSON

    class JHash < Hash
      include AttributeKit::JSONSerializableHash
    end

    attr_hash = JHash.new                                    #=> {}
    attr_hash[:foo] = 'bar'                                  #=> 'bar'
    attr_hash[:bar] = 5                                      #=> 5
    attr_hash                                                #=> {:foo=>"bar", :bar=>5}

    j = attr_hash.to_json                                    #=> "{\"foo\":\"bar\",\"bar\":5}"
    new_hash = JHash.new                                     #=> {}
    new_hash.from_json(j)                                    #=> {:foo=>"bar", :bar=>5}
    new_hash                                                 #=> {:foo=>"bar", :bar=>5}
    new_hash.clear                                           #=> {}

    f = attr_hash.get_json(:foo)                             #=> "{\"foo\":\"bar\"}"
    new_hash[:bar] = 5                                       #=> 5
    new_hash.store_json(f)                                   #=> {:bar=>5, :foo=>"bar"}
    new_hash                                                 #=> {:bar=>5, :foo=>"bar"}

## Serializing and deserializing an AttributeHash with JSON

    class MyHash < AttributeKit::AttributeHash
      include AttributeKit::JSONSerializableHash
    end

    attr_hash = MyHash.new                                   #=> {}
    attr_hash.empty?                                         #=> true
    attr_hash.dirty?                                         #=> false
    attr_hash[:foo] = 'bar'                                  #=> 'bar'
    attr_hash.dirty?                                         #=> true
    attr_hash.dirty_keys                                     #=> [:foo]
    attr_hash[:bar] = 5                                      #=> 5
    attr_hash                                                #=> {:foo=>"bar", :bar=>5}

    j = attr_hash.to_json                                    #=> "{\"foo\":\"bar\",\"bar\":5}"
    new_hash = MyHash.new                                    #=> {}
    new_hash.from_json(j)                                    #=> {:foo=>"bar", :bar=>5}
    new_hash                                                 #=> {:foo=>"bar", :bar=>5}
    new_hash.clear                                           #=> {}

    f = attr_hash.get_json(:foo)                             #=> "{\"foo\":\"bar\"}"
    new_hash[:bar] = 5                                       #=> 5
    new_hash.store_json(f)                                   #=> {:bar=>5, :foo=>"bar"}
    new_hash                                                 #=> {:bar=>5, :foo=>"bar"}

## Contributing to attribute-kit

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright and License

Copyright (c) 2011 Jonathan Mischo

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
