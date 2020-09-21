# typed: strict

module Result
  extend T::Generic
  extend T::Sig
  
  OkType = type_member
  ErrType = type_member
  
  sig do
    type_parameters(:N, :E)
      .params(v: T.type_parameter(:N))
      .returns(
        Result::Ok[T.type_parameter(:N), T.type_parameter(:E)]
      )
  end
  def self.ok(v)
    Result::Ok.new(v)
  end

  sig do
    type_parameters(:N, :E)
      .params(e: T.type_parameter(:E))
      .returns(
        Result::Err[T.type_parameter(:N), T.type_parameter(:E)]
      )
  end
  def self.err(e)
    Result::Err.new(e)
  end

  abstract!
  sig { abstract.returns(OkType) }
  def unwrap; end
    
  abstract!
  sig { abstract.returns(OkType) }
  def unwrap_err; end

  abstract!
  sig { abstract.returns(T::Boolean) }
  def ok?; end

  abstract!
  sig { abstract.returns(T::Boolean) }
  def err?; end

  abstract!
  sig do
    type_parameters(:N1, :N2, :E)
      .params(
        blk: T.proc.params(arg0: T.type_parameter(:N1))
          .returns(T.type_parameter(:N2))
      )
      .abstract
      .returns(
        Result[T.type_parameter(:N2), T.type_parameter(:E)]
      )
  end
  def map(&blk); end

  class Ok
    include Result
    extend T::Generic
    extend T::Sig
    
    OkType = type_member
    ErrType = type_member
    
    sig { params(val: OkType).void }
    def initialize(val)
      @val = T.let(val, OkType)
    end

    sig{ override.returns(OkType) }
    def unwrap
      @val
    end
  
    sig { override.returns(OkType) }
    def unwrap_err
      raise 'Called unwrap_err on an Ok type'
    end
  
    sig { override.returns(T::Boolean) }
    def ok?
      true
    end
  
    sig { override.returns(T::Boolean) }
    def err?
      false
    end

    sig do
      type_parameters(:O, :E)
        .override
        .params(
          blk: T.proc.params(arg0: OkType)
            .returns(T.type_parameter(:O))
        )
        .returns(Result[T.type_parameter(:O), T.type_parameter(:E)])
    end
    def map(&blk)
      self.class.new(blk.call(@val))
    end
  end

  class Err
    include Result
    extend T::Generic
    extend T::Sig
    
    OkType = type_member
    ErrType = type_member
    
    sig{params(val: ErrType).void}
    def initialize(val)
      @val = T.let(val, ErrType)
    end

    sig{ override.returns(OkType) }
    def unwrap
      raise 'Called unwrap on an Err type'
    end
  
    sig{ override.returns(ErrType) }
    def unwrap_err
      @val
    end
  
    sig{ override.returns(T::Boolean) }
    def ok?
      false
    end
  
    sig{ override.returns(T::Boolean) }
    def err?
      true
    end
    
    sig do
      type_parameters(:N1, :N2, :E)
        .override
        .params(blk: T.proc.params(arg0: T.type_parameter(:N1)).returns(T.type_parameter(:N2)))
        .returns(Result[T.type_parameter(:N2), T.type_parameter(:E)])
    end
    def map(&blk)
      self.class.new(@val)
    end
  end
end

#----------#
# EXAMPLES #
#----------#

extend T::Sig

sig do
  params(string: String).returns(Result[Integer, T.untyped])
end
def parse_integer(string)
  Result::Ok.new(Integer(string))
rescue ArgumentError => e
  Result::Err.new(e)
  # This compiles, but it shouldn't:
  #
  # rescue Exception => e
  #   Result::Err.new(e)
end

sig{params(result: Result[String, T.untyped]).void}
def print_ok_val(result)
  if result.ok?
    puts(result.unwrap)
  end
end

result = Result.ok(1) # Shortcut for `Result::Ok.new(1)`
print_ok_val(result.map(&:to_s))

result = parse_integer("hi")
print_ok_val(result.map(&:to_s))
