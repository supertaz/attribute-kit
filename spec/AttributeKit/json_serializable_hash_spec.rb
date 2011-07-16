require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class JSONSerializableHashTestHash < Hash
  include AttributeKit::JSONSerializableHash
end

describe "AttributeKit" do
  context '::JSONSerializableHash' do
    it 'should load' do
      defined?(AttributeKit::JSONSerializableHash).should == 'constant'
    end

    before(:each) do
      @hash = JSONSerializableHashTestHash.new
      @hash[:a] = 'a'
      @hash[:b] = 2
      @hash[:c] = nil
      @hash[:float] = 3.14
      @hash[:integer] = 5.to_i
    end

    context '#to_json' do
      it 'should serialize the contents of the hash to JSON' do
        json = @hash.to_json
        json.should == '{"a":"a","b":2,"c":null,"float":3.14,"integer":5}'
      end
    end

    context '#from_json' do
      before(:each) do
        @new_hash = JSONSerializableHashTestHash.new
        @new_hash.from_json('{"a":"a","b":2,"c":null,"float":3.14,"integer":5}')
      end

      it 'should use symbols for the keys instead of strings or other objects' do
        @new_hash.has_key?(:a).should be_true
        @new_hash.has_key?('a').should be_false
      end

      it 'should deserialize JSON into the correct contents of the hash' do
        @new_hash.length.should == 5
        @new_hash[:a].should == 'a'
        @new_hash[:b].should == 2
        @new_hash[:c].should be_nil
        @new_hash[:float].should == 3.14
        @new_hash[:integer].should == 5
      end
    end

    context '#get_json' do
      it 'should retrieve a key-value pair with a String value and JSON encode it' do
        json = @hash.get_json(:a)
        json.should == '{"a":"a"}'
      end

      it 'should retrieve a key-value pair with a Fixnum value and JSON encode it' do
        json = @hash.get_json(:b)
        json.should == '{"b":2}'
      end

      it 'should retrieve a key-value pair with a Nil value and JSON encode it' do
        json = @hash.get_json(:c)
        json.should == '{"c":null}'
      end

      it 'should retrieve a key-value pair with a Float value and JSON encode it' do
        json = @hash.get_json(:float)
        json.should == '{"float":3.14}'
      end

      it 'should retrieve a key-value pair with an Integer value and JSON encode it' do
        json = @hash.get_json(:integer)
        json.should == '{"integer":5}'
      end
    end

    context '#store_json' do
      before(:each) do
        @new_hash = JSONSerializableHashTestHash.new
        @new_hash.store_json('{"a":"a"}')
      end

      it 'should use symbols for the keys instead of strings or other objects' do
        @new_hash.has_key?(:a).should be_true
        @new_hash.has_key?('a').should be_false
      end

      it 'should parse the provided JSON and store it as a key-value pair' do
        @new_hash[:a].should == 'a'
      end

      it 'should parse the provided JSON and replace an existing key-value pair' do
        @new_hash.store_json('{"a":"b"}')
        @new_hash[:a].should == 'b'
      end
    end
  end
end
