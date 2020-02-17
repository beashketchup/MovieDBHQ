extension Optional {

  public func unwrapOrThrow(error: Error) throws -> Wrapped {
    if let value = self {
      return value
    } else {
      throw error
    }
  }
}
