require 'builder_builder'

describe 'when building builders' do
  specify "a builder's default attributes are single objects" do
    build = Proc.new do
      validate
      @req
    end

    TestBuilder = builder(build) do
      required :req
    end

    def test &block
      Docile.dsl_eval(TestBuilder.new, &block).build
    end

    foostring = test {req "foo"}

    expect(foostring).to eq "foo"
  end

  specify 'a builder has a default build function' do
    TestBuilder2 = builder {required :req, :req2}

    def test &block
      Docile.dsl_eval(TestBuilder2.new, &block).build
    end

    default_build_map = test {
      req "val"
      req2 "number"
    }

    expect(default_build_map.length).to be(2)
    expect(default_build_map).to be_an_instance_of(Hash)
    expect(default_build_map[:req]).to eq("val")
  end

  specify 'a builder can have a default valued attribute' do
    TestDefaultBuilder = builder {defaulted :three, 3}
    def test &block
      Docile.dsl_eval(TestDefaultBuilder.new, &block).build
    end

    defaulted = test {}
    not_defaulted = test {three 5}

    expect(defaulted[:three]).to be(3)
    expect(not_defaulted[:three]).to be(5)
  end

  specify 'a builder can have an optional value' do
    TestOptionalBuilder = builder {optional :foo}
    def test &block
      Docile.dsl_eval(TestOptionalBuilder.new, &block).build
    end

    optional = test {}
    optional_is_used = test {foo 5}

    expect(optional[:foo]).to be(nil)
    expect(optional_is_used[:foo]).to be(5)
  end

  specify 'a builder can accumulate a value' do
    TestAccumulatorBuilder = builder {accumulates :bname, :pname}
    def test &block
      Docile.dsl_eval(TestAccumulatorBuilder.new, &block).build
    end

    accumulated = test do
      bname 1
      bname 2
      bname 3
    end

    not_accumulated = test do
    end

    expect(accumulated[:pname]).to eq [1,2,3]
    not_accumulated[:pname].should eq []
  end

  specify 'a builder can have a boolean value' do
    TestBooleanBuilder = builder {boolean :a; boolean :b; boolean :c}
    def test &block
      Docile.dsl_eval(TestBooleanBuilder.new, &block).build
    end

    boolean = test do
      is a
      isnt b
    end

    boolean[:a].should be_true
    boolean[:b].should be_false
    boolean[:c].should be_false
  end
end
