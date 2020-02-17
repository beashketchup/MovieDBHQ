import Prelude

/**
 A list of possible requests that can be made for Cartrack data.
 */
internal enum Route {
  case playingNow([String: String])
  case similarMovies(Int, [String: String])
  
  internal var requestProperties:
    (method: Method, encoding: Encoding, path: String, query: [String: String]) {
    
    switch self {
    case let .playingNow(query):
      return (.GET, .none, "movie/now_playing", query)
    case let .similarMovies(movieId, query):
      return (.GET, .none, "movie/\(movieId)/similar", query)
    }
  }
}


