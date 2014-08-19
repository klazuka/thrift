import Foundation

// generic curry function for functions with 2 and 3 arguments, respectively
func curry<A,B,R>(f: ((A,B) -> R)) -> A -> B -> R {
    return { a in { b in f(a,b) }}
}
func curry<A,B,C,R>(f: ((A,B,C) -> R)) -> A -> B -> C -> R {
    return { a in { b in { c in f(a,b,c) }}}
}

// left fold
func foldl<A,B>(f: (A,B) -> A, initial: A, values: [B]) -> A {
    var acc = initial
    for v in values {
        acc = f(acc, v)
    }
    return acc
}

// right fold
func foldr<A,B>(f: (A,B) -> B, initial: B, values: [A]) -> B {
    var acc = initial
    for v in reverse(values) {
        acc = f(v, acc)
    }
    return acc
}

// function composition (f . g)
infix operator ⊙ { associativity right }
func ⊙<A,B,C>(f: B -> C, g: A -> B) -> A -> C {
    return { a in f(g(a)) }
}
