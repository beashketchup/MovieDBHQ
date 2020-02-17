public enum Method: String {
  case GET
  case POST
  case PUT
  case DELETE
}

public enum Encoding {
  case JSONEncoding
  case URLEncoding
  case FormDataEncoding
  case none
}
