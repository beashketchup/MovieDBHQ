import Foundation

public struct ErrorEnvelope {
  public let errorMessage: String
  public let error: BNSError
  public let errorCode: BNSCode
  public let code: Int

  public init(errorMessage: String, code: Int, error: BNSError, errorCode: BNSCode) {
    self.errorMessage = errorMessage
    self.error = error
    self.errorCode = errorCode
    self.code = code
  }

  public enum BNSError: String {
    case NoError = "NO_ERROR"
    case InvalidQuery = "INVALID_QUERY"
    case InternalServerError = "INTERNAL_SERVER_ERROR"

    public var code: Int {
      switch self {
      case .NoError: return 0
      case .InvalidQuery: return 422
      case .InternalServerError: return 500
      }
    }
  }

  public enum BNSCode: String {
    // Catch all code for when server sends code we don't know about yet
    case UnknownCode = "__internal_unknown_code"
    case DataRequestFailed = "data_request_failed"

    // Codes defined by the client
    case JSONParsingFailed = "json_parsing_failed"
    case JSONSerializeFailed = "json_serialize_failed"
    case ErrorEnvelopeJSONParsingFailed = "error_json_parsing_failed"
    case DecodingJSONFailed = "decoding_json_failed"

    // Codes when no error
    case NoError = "no_error"

    public var code: Int {
      switch self {
      case .UnknownCode: return 9_999
      case .DataRequestFailed: return 600
      case .JSONParsingFailed: return 601
      case .JSONSerializeFailed: return 602
      case .ErrorEnvelopeJSONParsingFailed: return 603
      case .DecodingJSONFailed: return 604
      case .NoError: return 0
      }
    }
  }

  public static let unknownError = ErrorEnvelope(
    errorMessage: "",
    code: BNSCode.UnknownCode.code,
    error: .InternalServerError,
    errorCode: .UnknownCode
  )

  public static let noError = ErrorEnvelope(
    errorMessage: "",
    code: BNSCode.NoError.code,
    error: .NoError,
    errorCode: .NoError
  )

  public static let requestFailed = ErrorEnvelope(
    errorMessage: "",
    code: BNSCode.DataRequestFailed.code,
    error: .InvalidQuery,
    errorCode: .DataRequestFailed
  )

  public static let jsonParsingFailed = ErrorEnvelope(
    errorMessage: "",
    code: BNSCode.JSONParsingFailed.code,
    error: .InternalServerError,
    errorCode: .JSONParsingFailed
  )

  public static let errorEnvelopeParsingFailed = ErrorEnvelope(
    errorMessage: "",
    code: BNSCode.ErrorEnvelopeJSONParsingFailed.code,
    error: .InternalServerError,
    errorCode: .ErrorEnvelopeJSONParsingFailed
  )

  public static func decodingJSONFailed(_ decodeError: Error? = nil) -> ErrorEnvelope {
    return ErrorEnvelope(
      errorMessage: decodeError?.localizedDescription ?? "",
      code: BNSCode.DecodingJSONFailed.code,
      error: .InternalServerError,
      errorCode: .DecodingJSONFailed
    )
  }
}

extension ErrorEnvelope: Error {}

extension ErrorEnvelope: Equatable {}
public func == (lhs: ErrorEnvelope, rhs: ErrorEnvelope) -> Bool {
  return lhs.error == rhs.error &&
    lhs.errorCode == rhs.errorCode
}
