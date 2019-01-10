# sorbet-result

A result type for Sorbet. API is similar to [Rust’s `Result`](https://doc.rust-lang.org/std/result/).

## Examples

```ruby
sig { params(string: String).returns(Result[Integer, ArgumentError]) }
def parse_integer(string)
  Result.ok(Integer(string))
rescue ArgumentError => e
  Result.err(e)
end

sig { params(result: Result[String, T.untyped]).void }
def print_ok_val(result)
  if result.ok?
    puts(result.unwrap)
  end
end

result = Result.ok(1) # Shortcut for `Result::Ok.new(1)`
print_ok_val(result.map(&:to_s))

result = parse_integer("hi")
print_ok_val(result.map(&:to_s))
```

## License

All files licensed [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
