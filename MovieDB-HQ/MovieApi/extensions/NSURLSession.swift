import Foundation
import ReactiveSwift

private let scheduler = QueueScheduler(qos: .background, name: "com.HQ.test", targeting: nil)

private let defaultSessionError = NSError(domain: "com.HQ.test.dataResponse", code: 1, userInfo: nil)

internal extension URLSession {
  // Wrap an URLSession producer with Graph error envelope logic.
  func rac_dataResponse(_ request: URLRequest)
    -> SignalProducer<Data, ErrorEnvelope> {
      let producer = SignalProducer<(Data, URLResponse), Error> { observer, disposable in
        let task = self.dataTask(with: request) { data, response, error in
          guard let data = data, let response = response else {
            observer.send(error: error ?? defaultSessionError)
            return
          }
          print("🍏 TASK FINISHED")
          observer.send(value: (data, response))
          observer.sendCompleted()
        }
        disposable.observeEnded {
          print("🍎 TASK ENDED")
          task.cancel()
        }
        task.resume()
      }
      
      return producer
        .start(on: scheduler)
        .flatMapError { error -> SignalProducer<(Data, URLResponse), ErrorEnvelope> in
          print("🔴 [BnsApi] Request Error \(error.localizedDescription)")
          
          return .init(error: ErrorEnvelope.requestFailed)
        }
        .flatMap(.concat) { data, response -> SignalProducer<Data, ErrorEnvelope> in
          guard let response = response as? HTTPURLResponse else { fatalError() }
          
          guard self.isValidResponse(response: response) else {
            print("🔴 [BnsApi] HTTP Failure \(request)")
            return SignalProducer<Data, ErrorEnvelope>(error: .requestFailed)
          }
          
          print("🔵 [BnsApi] HTTP Success \(request)")
          return SignalProducer<Data, ErrorEnvelope>(value: data)
      }
  }
  
  private func isValidResponse(response: HTTPURLResponse) -> Bool {
    guard (200..<300).contains(response.statusCode),
      let headers = response.allHeaderFields as? [String: String],
      let contentType = headers["Content-Type"], contentType.hasPrefix("application/json") else {
        return false
    }
    
    return true
  }
}
