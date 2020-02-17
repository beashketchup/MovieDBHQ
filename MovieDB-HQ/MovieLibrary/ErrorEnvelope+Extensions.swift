import MovieApi

extension ErrorEnvelope {

  internal var description: String {
    switch self.error {
    case .InvalidQuery:
      return "Invalid Query. (MD-\(self.code))"
    case .NoError:
      return "No Error"
    case .InternalServerError:
      return "Internal server error. (MD-\(self.code))"
    }
  }

  public var errorDescription: String {
    switch self.errorCode {
    case .DataRequestFailed:
      return "Failed to make data request. (MD-\(self.code))"
    case .DecodingJSONFailed:
      return "Unable to decode data. (MD-\(self.code))"
    case .ErrorEnvelopeJSONParsingFailed:
      return "Unable to parse error. (MD-\(self.code))"
    case .JSONParsingFailed:
      return "Unable to parse data. (MD-\(self.code))"
    case .NoError:
      return "No Error"
    default:
      return self.description
    }
  }
}
