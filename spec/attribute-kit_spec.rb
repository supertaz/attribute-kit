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
