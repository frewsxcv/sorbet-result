Bool = T.type_alias(T.any(TrueClass, FalseClass))

module Result
  extend T::Helpers
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
  end
end

result = Result.ok(1) # Shortcut for `Result::Ok.new(1)`
result.ok?
val = result.unwrap
