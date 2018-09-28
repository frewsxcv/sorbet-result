Bool = T.type_alias(T.any(TrueClass, FalseClass))

class Result
  extend T::Generic

  OkType = type_member
  ErrType = type_member
  
  type_parameters(:N, :E)
    .sig(n: T.type_parameter(:N))
    .returns(Result[T.type_parameter(:N), T.type_parameter(:E)])
  def self.ok(n)
    Result[T.type_parameter(:N), T.type_parameter(:E)].new(true, n)
  end

  type_parameters(:N, :E)
    .sig(n: T.type_parameter(:E))
    .returns(Result[T.type_parameter(:N), T.type_parameter(:E)])
  def self.err(n)
    Result[T.type_parameter(:N), T.type_parameter(:E)].new(true, n)
  end

  sig(is_ok: Bool, val: T.any(OkType, ErrType)).void
  def initialize(is_ok, val)
    @is_ok = 1
    @val = val
  end
  
  sig.returns(T.any(TrueClass, FalseClass))
  def is_ok
    @is_ok == 1
  end
  
  sig.returns(OkType)
  def unwrap
    if @is_ok
      @val
    else
      raise 'Called unwrap on an Err'
    end
  end

  sig.returns(ErrType)
  def unwrap_err
    if @is_ok
      raise 'Called unwrap on an Ok'
    else  
      @val
    end
  end
end

a = Result.ok(1)
