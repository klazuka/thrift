import Foundation

//MARK:- the parser type

// The fundamental unit that the parser operates on will be a slice of bytes
typealias ByteString = Slice<UInt8>

// Conceptually the parser is a function that takes input bytes to a 
// pair of parsed result and remaining bytes, but the following typealias
// does not compile in Xcode6-Beta6 (I believe the problem is that you
// cannot make the typealias parameterized by a generic type):
//
//      typealias Parser<R> = ByteString -> ParseResult<R>
//
// So instead, declare a generic struct that's initialized with a closure
struct Parser<R> {
    let p: ByteString -> ParseResult<R>
}

// The input is always assumed to be of type `ByteString`
// `R` is the type of the parsed result (e.g. a UInt32).
// We must box the generic type variable to avoid an internal
// assertion failure in the Swift code generator (as of Xcode6-Beta6)
enum ParseResult<R> {
    case Done(Box<R>, ByteString)
    case Fail(ByteString)
//    case Partial(ByteString -> ParseResult<R>)
}

// convenience constructors to hide the boxing
private func pdone<R>(r: R, b: ByteString) -> ParseResult<R> {
    return ParseResult.Done(Box(r), b)
}
private func pfail<R>(b: ByteString) -> ParseResult<R> {
    return ParseResult.Fail(b)
}


// functor map
infix operator <^> { associativity left }
func <^><VA, VB>(f: VA -> VB, a: Parser<VA>) -> Parser<VB> {
    return fmapr(a, f)
}

// reversed fmap argument order
func fmapr<VA, VB>(a: Parser<VA>, f: VA -> VB) -> Parser<VB> {
    return Parser { s in
        switch run(a, s) {
        case let .Done(r, rest): return pdone(f(r.value), rest)
        case let .Fail(rest): return pfail(rest)
        }
    }
}

//MARK:- parse driver

func run<T>(parser: Parser<T>, input: ByteString) -> ParseResult<T> {
    return parser.p(input)
}

//MARK:- combinators

// sequence operator where the former result is discarded, and the latter is kept
infix operator ->> { associativity left }
func ->><A,B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
    return Parser { s in
        switch lhs.p(s) {
        case .Fail(let x): return ParseResult.Fail(x)
        case .Done(_, let s2):
            return rhs.p(s2)
        }
    }
}

// sequence operator where the former result is kept, and the latter is discarded
infix operator <<- { associativity left }
func <<-<A,B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<A> {
    return Parser { s in
        switch lhs.p(s) {
        case .Fail(let x): return ParseResult.Fail(x)
        case .Done(let a, let s2):
            switch rhs.p(s2) {
            case .Fail(let x): return ParseResult.Fail(x)
            case .Done(_, let s3):
                return ParseResult.Done(a, s3)
            }
        }
    }
}


infix operator <|> { associativity left }
func <|><A>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
    return Parser { s in
        switch lhs.p(s) {
        case .Fail(_):
            return rhs.p(s)
        case .Done(let a, let s2):
            return ParseResult.Done(a, s2)
        }
    }
}

func many1<A>(parser: Parser<A>) -> Parser<[A]> {
    return Parser { s in
        
        var list = [A]()
        var remainingInput = s
        loop: while true {
            switch parser.p(remainingInput) {
            case let .Fail(x):
                break loop
            case let .Done(a, s2):
                list.append(a.value)
                remainingInput = s2
            }
        }
        
        if list.count == 0 {
            return pfail(s)
        } else {
            return pdone(list, remainingInput)
        }
    }
}

// matches zero or more occurrences of `parser` up until `tillParser` matches once
func manyTill<A,B>(parser: Parser<A>, tillParser: Parser<B>) -> Parser<[A]> {
    return Parser { s in
        switch tillParser.p(s) {
        case .Fail(let x):
            return run(many1(parser) <<- tillParser, s)
        case .Done(_, let s2):
            return pdone([A](), s2)
        }
    }
}

//MARK:- core bytestring parsers

func parseAnyUInt8() -> Parser<UInt8> {
    return Parser { s in
        if let head = s.first {
            return pdone(head, s[1..<s.count])
        } else {
            return pfail(s)
        }
    }
}

//TODO: find a cleaner way to do this with less code duplication
func parseUInt8(byte: UInt8) -> Parser<UInt8?> {
    return Parser { (s: Slice<UInt8>) in
        if let head = s.first {
            return head == byte ? pdone(head, s[1..<s.count]) : pfail(s)
        } else {
            return pfail(s)
        }
    }
}

func parseTake(n: Int) -> Parser<ByteString> {
    return Parser { s in
        if s.count >= n {
            return pdone(s[0..<n], s[n..<s.count])
        } else {
            return pfail(s)
        }
    }
}


