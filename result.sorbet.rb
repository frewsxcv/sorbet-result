extend T::Helpers

Bool = T.type_alias(T.any(TrueClass, FalseClass))

module Result
  extend T::Generic
  
  OkType = type_member
  ErrType = type_member

  type_parameters(:N, :E)
    .sig(v: T.type_parameter(:N))
    .returns(Result::Ok[T.type_parameter(:N), T.type_parameter(:E)])
  def self.ok(v)
    Result::Ok[T.type_parameter(:N), T.type_parameter(:E)].new(v)
  end

  type_parameters(:N, :E)
    .sig(e: T.type_parameter(:E))
    .returns(Result::Err[T.type_parameter(:N), T.type_parameter(:E)])
  def self.err(e)
    Result::Err[T.type_parameter(:N), T.type_parameter(:E)].new(e)
  end

  abstract!
  sig.abstract.returns(OkType)
  def unwrap; end
    
  abstract!
  sig.abstract.returns(OkType)
  def unwrap_err; end

  abstract!
  sig.abstract.returns(Bool)
  def ok?; end

  abstract!
  sig.abstract.returns(Bool)
  def err?; end

  abstract!
  type_parameters(:N1, :N2, :E)
    .sig(blk: T.proc(arg0: T.type_parameter(:N1)).returns(T.type_parameter(:N2)))
    .abstract
    .returns(Result[T.type_parameter(:N2), T.type_parameter(:E)])
  def map(&blk); end

  class Ok
    include Result
    extend T::Generic
    
    OkType = type_member
    ErrType = type_member
    
    sig(val: OkType).void
    def initialize(val)
      @val = val
    end

    sig.returns(OkType)
    def unwrap
      @val
    end
  
    sig.returns(OkType)
    def unwrap_err
      raise 'Called unwrap_err on an Ok type'
    end
  
    sig.returns(Bool)
    def ok?
      true
    end
  
    sig.returns(Bool)
    def err?
      false
    end

    type_parameters(:N1, :N2, :E)
      .sig(blk: T.proc(arg0: T.type_parameter(:N1)).returns(T.type_parameter(:N2)))
      .returns(Result[T.type_parameter(:N2), T.type_parameter(:E)])
    def map(&blk)
      Result::Ok.new(blk.call(@val))
    end
  end

  class Err
    include Result
    extend T::Generic
    
    OkType = type_member
    ErrType = type_member
    
    sig(val: ErrType).void
    def initialize(val)
      @val = val
    end

    sig.returns(OkType)
    def unwrap
      raise 'Called unwrap on an Err type'
    end
  
    sig.returns(ErrType)
    def unwrap_err
      @val
    end
  
    sig.returns(Bool)
    def ok?
      false
    end
  
    sig.returns(Bool)
    def err?
      true
    end
    
    type_parameters(:N1, :N2, :E)
      .sig(blk: T.proc(arg0: T.type_parameter(:N1)).returns(T.type_parameter(:N2)))
      .returns(Result[T.type_parameter(:N2), T.type_parameter(:E)])
    def map(&blk)
      Result::Err.new(@val)
    end
  end
end

#----------#
# EXAMPLES #
#----------#

sig(string: String).returns(Result[Integer, ArgumentError])
def parse_integer(string)
  Result::Ok.new(Integer(string))
rescue ArgumentError => e
  Result::Err.new(e)
# This compiles, but it shouldn't:
#
# rescue Exception => e
#   Result::Err.new(e)
end

sig(result: Result[String, Exception]).void
def print_ok_val(result)
  if result.ok?
    puts(result.unwrap)
  end
end

# result = Result.ok(1) # Shortcut for `Result::Ok.new(1)`
# print_ok_val(result.map(&:to_s))

# result = parse_integer("hi")
# print_ok_val(result.map(&:to_s))
