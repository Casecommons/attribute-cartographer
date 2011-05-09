require 'spec_helper'

describe AttributeCartographer do
  after(:each) do
    TestClass.instance_variable_set :@mapper, nil
  end

  let(:klass) {
    class TestClass
      include AttributeCartographer
    end
  }

  describe "#initialize" do
    context "with nothing mapped" do
      it "does not try to map anything when map was not called" do
        lambda { klass.new(a: :b) }.should_not raise_error
      end
    end

    context "with attributes that don't match mapped values" do
      before { klass.map :a, :b, ->(v) { v + 1 } }

      it "maps attributes to nil when no mappable attribute was passed in" do
        klass.new(c: :d).b.should be_nil
      end
    end
  end

  describe "#original_attributes" do
    it "returns any attributes given to initialize" do
      klass.new(a: :b).original_attributes.should == { a: :b }
    end
  end

  describe ".map" do
    context "with a single argument given" do
      before { klass.map :a }

      it "creates an instance method matching the key name" do
        klass.new(:a => :a_value).a.should == :a_value
      end
    end

    context "with an empty array" do
      subject { klass.map [] }

      it "should raise an error" do
        lambda { klass.map [] }.should raise_error(AttributeCartographer::InvalidArgumentError)
      end
    end

    context "with a non-empty array" do
      before { klass.map [:a, :b] }

      it "creates a method named for each key" do
        instance = klass.new(a: :a_value, b: :b_value)
        instance.a.should == :a_value
        instance.b.should == :b_value
      end

      it "makes nil methods for mapped keys which had no attributes passed in for them" do
        instance = klass.new(a: :a_value)
        instance.b.should == nil
      end
    end

    context "with two keys and a 1-arity block given" do
      before { klass.map :a, :b, ->(v) { v + 1 } }

      it "creates a method named for the second key with the result of passing the associated value to the block" do
        klass.new(:a => 1).b.should == 2
      end
    end

    context "with two keys and a >1-arity block given" do
      it "raises an error" do
        lambda { klass.map :a, :b, ->(k,v) { v + 1 } }.should raise_error(AttributeCartographer::InvalidArgumentError)
      end
    end
  end
end
