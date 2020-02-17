@testable import MovieApi

import XCTest

final class ServiceTypeTests: XCTestCase {
  private let service = Service(
    appId: "com.HQ.test",
    serverConfig: ServerConfig(
      apiBaseUrl: URL(string: "http://api.hq.com")!,
      environment: .production,
      serverTrustPolicyManager: ServerTrustPolicyManager(
        policies: Secrets.Api.policy
      )
    ),
    language: "hq",
    buildVersion: "1234567890"
  )
  
  func testPreparedRequest() {
    let url = URL(string: "http://api.hq.com/v1")!
    let request = self.service.preparedRequest(forRequest: .init(url: url), query: [:])
    
    XCTAssertEqual(
      "http://api.hq.com/v1?api_key=b5c34c996b0f93d624c485c79881e04b&language=en-US",
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Accept-Language": "hq",
        "User-Agent": userAgent()
      ],
      request.allHTTPHeaderFields!
    )
  }
  
  func testPreparedURL() {
    let url = URL(string: "http://api.hq.com/v1")!
    let request = self.service.preparedRequest(forURL: url, query: ["page": "1"])
    
    XCTAssertEqual(
      "http://api.hq.com/v1?api_key=b5c34c996b0f93d624c485c79881e04b&language=en-US&page=1",
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Accept-Language": "hq",
        "User-Agent": userAgent()
      ],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("GET", request.httpMethod)
  }
}

// swiftlint:disable line_length
private func userAgent() -> String {
  return """
  com.apple.dt.xctest.tool/\(testToolBuildNumber()) (\(UIDevice.current.model); iOS \(UIDevice.current.systemVersion) Scale/\(UIScreen.main.scale))
  """
}

// swiftlint:enable line_length

private func testToolBuildNumber() -> Double {
  guard
    let buildString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
    let buildNumber = Double(buildString)
    else { return 0 }
  
  return buildNumber
}
