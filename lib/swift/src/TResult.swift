import Foundation

class TError: NSError {
    enum Domain: String {
        case Application = "application"
        case Protocol = "protocol"
        case Transport = "transport"
    }
}


func err<T>(domain: TError.Domain, msg: String) -> Result<T> {
    return Result.error(TError(domain: domain.toRaw(), code: -1, userInfo: [NSLocalizedDescriptionKey: msg]))
}

func ok<T>(v: T) -> Result<T> {
    return Result.value(v)
}

//infix operator <^^> {
//    associativity left
//}
//func <^^><VA, VB>(a: Result<VA>, f: VA -> VB) -> Result<VB> {
//    return f <^> a
//}
//
//// hack to provide nicer syntax for a sequence of error-ful computations
//infix operator >>- { associativity left }
//func >>-<T, NT>(result: Result<T>, next: @autoclosure () -> Result<NT>) -> Result<NT> {
//    switch result {
//    case let .Error(l): return .Error(l)
//    case let .Value(r): return next()
//    }
//}
//
//
//
//// ---------------------------------------------
//// porting Haskell's replicateM and replicateM_
//
//func replicateM<T>(n: Int, action: () -> Result<T>) -> Result<[T]> {
//    var xs = [T]()
//    for _ in 1...n {
//        switch action() {
//        case .Error(let e):
//            return .Error(e)
//        case .Value(let boxed):
//            xs.append(boxed.value)
//        }
//    }
//    return Result.value(xs)
//}
//
//func replicateM_<T>(n: Int, action: () -> Result<T>) -> Result<()> {
//    for _ in 1...n {
//        action()
//    }
//    return Result.value()
//}
