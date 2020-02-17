public func == <A: Equatable, B: Equatable> (lhs: [(A, B)], rhs: [(A, B)]) -> Bool {
  guard lhs.count == rhs.count else { return false }

  for idx in lhs.indices {
    if lhs[idx] != rhs[idx] {
      return false
    }
  }
  return true
}

/**
 - parameter t: A 2-tuple.
 - returns: The first value of a 2-tuple.
 */
public func first<A, B>(_ t: (A, B)) -> A {
  return t.0
}

/**
 - parameter t: A 2-tuple.
 - returns: The second value of a 2-tuple.
 */
public func second<A, B>(_ t: (A, B)) -> B {
  return t.1
}

/**
 - parameter t: A 3-tuple.
 - returns: The first value of a 3-tuple.
 */
public func first<A, B, C>(_ t: (A, B, C)) -> A {
  return t.0
}

/**
 - parameter t: A 3-tuple.
 - returns: The second value of a 3-tuple.
 */
public func second<A, B, C>(_ t: (A, B, C)) -> B {
  return t.1
}

/**
 - parameter t: A 3-tuple.
 - returns: The third value of a 3-tuple.
 */
public func third<A, B, C>(_ t: (A, B, C)) -> C {
  return t.2
}

public func +| <A, B, C, D, E>(_ t: (A, B), tail: (C, D, E)) -> (A, B, C, D, E) {
  return (t.0, t.1, tail.0, tail.1, tail.2)
}

/**
 - parameter t: A 2-tuple.
 - returns: A 3-tuple.
 */

public func +| <A, B, C>(_ t: (A, B), tail: C) -> (A, B, C) {
  return (t.0, t.1, tail)
}

/**
 - parameter t: A 3-tuple.
 - returns: A 4-tuple.
 */

public func +| <A, B, C, D>(_ t: (A, B, C), tail: D) -> (A, B, C, D) {
  return (t.0, t.1, t.2, tail)
}

/**
 - parameter t: A 4-tuple.
 - returns: A 5-tuple.
 */

public func +| <A, B, C, D, E>(_ t: (A, B, C, D), tail: E) -> (A, B, C, D, E) {
  return (t.0, t.1, t.2, t.3, tail)
}

/**
 - parameter t: A 5-tuple.
 - returns: A 6-tuple.
 */

public func +| <A, B, C, D, E, F>(_ t: (A, B, C, D, E), tail: F) -> (A, B, C, D, E, F) {
  return (t.0, t.1, t.2, t.3, t.4, tail)
}
