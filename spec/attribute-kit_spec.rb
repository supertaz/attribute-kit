require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AttributeKit" do
  it "loads" do
    defined?(AttributeKit).should == 'constant'
  end

  describe "::AttributeHash" do
    describe '#new' do
      it "should return an empty AttributeHash when initialized without arguments" do
        test_hash = AttributeKit::AttributeHash.new
        test_hash.empty?.should be_true
      end

      it 'should return a 0 length AttributeHash when initialized' do
        test_hash = AttributeKit::AttributeHash.new
        test_hash.length.should == 0
      end

      it "should return a default value for invalid keys when initialized with a default value" do
        test_hash = AttributeKit::AttributeHash.new('blue')
        test_hash.empty?.should be_true
        test_hash[:blue].should == 'blue'
        test_hash[:red].should == 'blue'
      end

      it "should execute and return the result of a block for invalid keys when initialized with a block" do
        test_hash = AttributeKit::AttributeHash.new { |hash, key| [hash, key] }
        test_hash.empty?.should be_true
        test_hash[:blue].eql?([test_hash, :blue]).should be_true
        test_hash[:red].eql?([test_hash, :red]).should be_true
      end
    end

    describe '#[]=' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
      end

      it "should store a value" do
        @test_hash.empty?.should be_false
        @test_hash[:blue].should == 'blue'
      end

      it "should mark the attribute as dirty" do
        @test_hash.blue_dirty?.should be_true
      end

      it "should not mark the attribute as deleted" do
        @test_hash.blue_deleted?.should be_false
      end

      it "should mark the AttributeHash as dirty" do
        @test_hash.dirty?.should be_true
      end

      it "should return the value set" do
        ret = @test_hash[:red] = 'red'
        ret.should == 'red'
      end
    end

    describe '#store' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash.store(:blue, 'blue')
      end

      it "should store a value" do
        @test_hash.empty?.should be_false
        @test_hash[:blue].should == 'blue'
      end

      it "should be dirty" do
        @test_hash.blue_dirty?.should be_true
      end

      it "should not be deleted" do
        @test_hash.blue_deleted?.should be_false
      end

      it "should return the value set" do
        ret = @test_hash.store(:red, 'red')
        ret.should == 'red'
      end
    end

    describe '#[]' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new('red')
        @test_hash[:blue] = 'blue'
        @test_hash.clean_attributes {}
      end

      it "should get a correct value (sanity check)" do
        @test_hash.empty?.should be_false
        @test_hash[:blue].should == 'blue'
      end

      it "should be clean" do
        @test_hash.dirty?.should be_false
      end
    end

    describe '#delete' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash.clean_attributes {}
        @test_hash.delete(:blue)
      end

      it "should delete a value" do
        @test_hash[:blue].should be_nil
        @test_hash.empty?.should be_true
      end

      it "should mark the attribute as deleted" do
        @test_hash.blue_deleted?.should be_true
      end

      it "should mark the AttributeHash as dirty" do
        @test_hash.dirty?.should be_true
      end

      it "should include the attribute in dirty_keys" do
        @test_hash.dirty_keys.include?(:blue).should be_true
      end

      it "should include the attribute in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_true
      end
    end

    describe '#delete_if' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash.clean_attributes {}
        @test_hash.delete_if {|k,v| v == 'blue'}
      end

      it "should delete only the matching items" do
        @test_hash[:blue].should be_nil
        @test_hash[:red].should == 'red'
      end

      it "should mark deleted attributes as deleted" do
        @test_hash.blue_deleted?.should be_true
      end

      it "should not mark untouched attributes as deleted" do
        @test_hash.red_deleted?.should be_false
      end

      it "should include deleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:blue).should be_true
      end

      it "should include deleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_true
      end

      it "should not include undeleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:red).should be_false
      end

      it "should not include undeleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:red).should be_false
      end

      it "should mark the AttributeHash as dirty" do
        @test_hash.dirty?.should be_true
      end
    end

    describe '#keep_if' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash.clean_attributes {}
        @test_hash.keep_if {|k,v| v == 'red'}
      end

      it "should delete only the matching items" do
        @test_hash[:blue].should be_nil
        @test_hash[:red].should == 'red'
      end

      it "should mark deleted attributes as deleted" do
        @test_hash.blue_deleted?.should be_true
      end

      it "should not mark untouched attributes as deleted" do
        @test_hash.red_deleted?.should be_false
      end

      it "should include deleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:blue).should be_true
      end

      it "should include deleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_true
      end

      it "should not include undeleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:red).should be_false
      end

      it "should not include undeleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:red).should be_false
      end

      it "should mark the AttributeHash as dirty" do
        @test_hash.dirty?.should be_true
      end
    end

    describe '#reject!' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash.clean_attributes {}
        @test_hash.reject! {|k,v| v == 'blue'}
      end

      it "should delete only the matching items" do
        @test_hash[:blue].should be_nil
        @test_hash[:red].should == 'red'
      end

      it "should mark deleted attributes as deleted" do
        @test_hash.blue_deleted?.should be_true
      end

      it "should not mark untouched attributes as deleted" do
        @test_hash.red_deleted?.should be_false
      end

      it "should include deleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:blue).should be_true
      end

      it "should include deleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_true
      end

      it "should not include undeleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:red).should be_false
      end

      it "should not include undeleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:red).should be_false
      end

      it "should mark the AttributeHash as dirty" do
        @test_hash.dirty?.should be_true
      end

      it "should return nil if no changes are made" do
        test_hash = AttributeKit::AttributeHash.new
        test_hash[:blue] = 'blue'
        test_hash.clean_attributes {}
        ret = test_hash.reject! {|k,v| v == 'red'}
        ret.should be_nil
      end
    end

    describe '#select!' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash.clean_attributes {}
        @test_hash.select! {|k,v| v == 'red'}
      end

      it "should delete only the matching items" do
        @test_hash[:blue].should be_nil
        @test_hash[:red].should == 'red'
      end

      it "should mark deleted attributes as deleted" do
        @test_hash.blue_deleted?.should be_true
      end

      it "should not mark untouched attributes as deleted" do
        @test_hash.red_deleted?.should be_false
      end

      it "should include deleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:blue).should be_true
      end

      it "should include deleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_true
      end

      it "should not include undeleted attributes in dirty_keys" do
        @test_hash.dirty_keys.include?(:red).should be_false
      end

      it "should not include undeleted attributes in deleted_keys" do
        @test_hash.deleted_keys.include?(:red).should be_false
      end

      it "should mark the AttributeHash as dirty" do
        @test_hash.dirty?.should be_true
      end

      it "should return nil if no changes are made" do
        test_hash = AttributeKit::AttributeHash.new
        test_hash[:blue] = 'blue'
        test_hash.clean_attributes {}
        ret = test_hash.select! {|k,v| v == 'blue'}
        ret.should be_nil
      end
    end

    describe "#replace" do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash.clean_attributes {}
        @ret_val = @test_hash.replace({:yellow => 'yellow', :green => 'green'})
      end

      it "should remove old contents" do
        @test_hash[:blue].should be_nil
        @test_hash[:red].should be_nil
      end

      it "should replace contents with supplied hash's contents" do
        @test_hash[:yellow].should == 'yellow'
        @test_hash[:green].should == 'green'
      end

      it "should mark old attributes as deleted" do
        @test_hash.blue_deleted?.should be_true
        @test_hash.red_deleted?.should be_true
      end

      it "should mark new attributes as dirty" do
        @test_hash.yellow_dirty?.should be_true
        @test_hash.green_dirty?.should be_true
      end

      it "should include old keys in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_true
        @test_hash.deleted_keys.include?(:red).should be_true
      end

      it "should not include new keys in deleted_keys" do
        @test_hash.deleted_keys.include?(:yellow).should be_false
        @test_hash.deleted_keys.include?(:green).should be_false
      end

      it "should mark instance as dirty" do
        @test_hash.dirty?.should be_true
      end

      it "should return an AttributeHash containing the new contents" do
        @ret_val.class.should == AttributeKit::AttributeHash
        @ret_val.eql?({:yellow => 'yellow', :green => 'green'}).should be_true
      end
    end

    describe "#merge!" do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash[:green] = 'grn'
        @test_hash.clean_attributes {}
        @ret_val = @test_hash.merge!({:yellow => 'yellow', :green => 'green'})
      end

      it "should retain unupdated contents" do
        @test_hash.blue_deleted?.should be_false
        @test_hash.red_deleted?.should be_false
        @test_hash[:blue].should == 'blue'
        @test_hash[:red].should == 'red'
      end

      it "should add supplied hash's contents to object's contents" do
        @test_hash[:yellow].should == 'yellow'
        @test_hash[:green].should == 'green'
      end

      it "should mark new attributes as dirty" do
        @test_hash.yellow_dirty?.should be_true
      end

      it "should mark changed attributes as dirty" do
        @test_hash.green_dirty?.should be_true
      end

      it "should not include unupdated keys in dirty_keys" do
        @test_hash.dirty_keys.include?(:blue).should be_false
        @test_hash.dirty_keys.include?(:red).should be_false
      end

      it "should include new keys in dirty_keys" do
        @test_hash.dirty_keys.include?(:yellow).should be_true
      end

      it "should include changed keys in dirty_keys" do
        @test_hash.dirty_keys.include?(:green).should be_true
      end

      it "should not include unupdated keys in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_false
        @test_hash.deleted_keys.include?(:red).should be_false
      end

      it "should not include new keys in deleted_keys" do
        @test_hash.deleted_keys.include?(:yellow).should be_false
        @test_hash.deleted_keys.include?(:green).should be_false
      end

      it "should mark instance as dirty" do
        @test_hash.dirty?.should be_true
      end

      it "should return an AttributeHash containing the new contents" do
        @ret_val.class.should == AttributeKit::AttributeHash
        @ret_val.eql?({:blue => 'blue', :red => 'red', :yellow => 'yellow', :green => 'green'}).should be_true
      end
    end

    describe "#update" do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash[:green] = 'grn'
        @test_hash.clean_attributes {}
        @ret_val = @test_hash.update({:yellow => 'yellow', :green => 'green'})
      end

      it "should retain unupdated contents" do
        @test_hash.blue_deleted?.should be_false
        @test_hash.red_deleted?.should be_false
        @test_hash[:blue].should == 'blue'
        @test_hash[:red].should == 'red'
      end

      it "should add supplied hash's contents to object's contents" do
        @test_hash[:yellow].should == 'yellow'
        @test_hash[:green].should == 'green'
      end

      it "should mark new attributes as dirty" do
        @test_hash.yellow_dirty?.should be_true
      end

      it "should mark changed attributes as dirty" do
        @test_hash.green_dirty?.should be_true
      end

      it "should not include unupdated keys in dirty_keys" do
        @test_hash.dirty_keys.include?(:blue).should be_false
        @test_hash.dirty_keys.include?(:red).should be_false
      end

      it "should include new keys in dirty_keys" do
        @test_hash.dirty_keys.include?(:yellow).should be_true
      end

      it "should include changed keys in dirty_keys" do
        @test_hash.dirty_keys.include?(:green).should be_true
      end

      it "should not include unupdated keys in deleted_keys" do
        @test_hash.deleted_keys.include?(:blue).should be_false
        @test_hash.deleted_keys.include?(:red).should be_false
      end

      it "should not include new keys in deleted_keys" do
        @test_hash.deleted_keys.include?(:yellow).should be_false
        @test_hash.deleted_keys.include?(:green).should be_false
      end

      it "should mark instance as dirty" do
        @test_hash.dirty?.should be_true
      end

      it "should return an AttributeHash containing the new contents" do
        @ret_val.class.should == AttributeKit::AttributeHash
        @ret_val.eql?({:blue => 'blue', :red => 'red', :yellow => 'yellow', :green => 'green'}).should be_true
      end
    end

    describe '#clean_attributes' do
      before(:each) do
        @test_hash = AttributeKit::AttributeHash.new
        @test_hash[:blue] = 'blue'
        @test_hash[:red] = 'red'
        @test_hash.delete(:red)
        @test_hash.clean_attributes {}
      end

      it "should unmark the hash as dirty" do
        @test_hash.dirty?.should be_false
      end

      it "should unmark an attribute as dirty" do
        @test_hash.blue_dirty.should be_false
      end

      it "should unmark an attribute as deleted" do
        @test_hash.red_deleted?.should be_false
      end
    end

  end
end
