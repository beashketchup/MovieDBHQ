import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  private func decodeModel<T: Swift.Decodable>(_ jsonData: Data) -> SignalProducer<T, ErrorEnvelope> {
    return SignalProducer(value: jsonData)
      .flatMap { data -> SignalProducer<T, ErrorEnvelope> in
        do {
          let decodedObject = try JSONDecoder().decode(T.self, from: data)
          
          print("🔵 [BnsApi] Successfully Decoded Data")
          return .init(value: decodedObject)
        } catch {
          print("🔴 [BnsApi] Failure - Decoding error: \(error.localizedDescription)")
          return .init(error: .decodingJSONFailed(error))
        }
    }
  }
  
  // MARK: Public Request Functions
  
  func fetch<M: Swift.Decodable>(_ route: Route) -> SignalProducer<M, ErrorEnvelope> {
    
    let properties = route.requestProperties
    guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl) else {
      fatalError(
        "URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl) == nil"
      )
    }
    
    let request = self.preparedRequest(
      forURL: URL,
      query: properties.query
    )
    
    print("⚪️ [BnsApi] Starting query:\n \(request)")
    return self.session.rac_dataResponse(request)
      .flatMap(self.decodeModel)
  }
}

