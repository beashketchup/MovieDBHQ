@testable import MovieApi
import XCTest

final class CheckoutEnvelopeTests: XCTestCase {
  func testJsonDecoding() {
    let json: String = """
      {
      "page": 1,
      "results": [
      {
      "id": 1255,
      "video": false,
      "vote_count": 1161,
      "vote_average": 6.8,
      "title": "The Host",
      "release_date": "2006-07-27",
      "original_language": "ko",
      "original_title": "괴물",
      "genre_ids": [
        18,
        27,
        878
      ],
      "backdrop_path": "/9diyJ180qJP4PHlHYPvwEMrrqI8.jpg",
      "adult": false,
      "overview": "Gang-du is a dim-witted man working at his father's tiny snack bar near the Han River. Following the dumping of gallons of toxic waste in the river, a giant mutated squid-like appears and begins attacking the populace.  Gang-du's daughter Hyun-seo is snatched up by the creature and he and his family are taken into custody by the military, who fear a virus spread by the creature.  In detention, Gang-du receives a phone call from Hyun-seo, who is not dead, merely trapped in a sewer.  With his family to assist him, he sets off to find Hyun-seo.",
      "poster_path": "/wLe2XnBHv5jJWIv5URin7vyCHbd.jpg",
      "popularity": 22.253
      },
      {
      "id": 2440,
      "video": false,
      "vote_count": 260,
      "vote_average": 7.8,
      "title": "Joint Security Area",
      "release_date": "2000-09-09",
      "original_language": "ko",
      "original_title": "공동경비구역 JSA",
      "genre_ids": [
        28,
        18,
        53,
        10752
      ],
      "backdrop_path": "/dNx1OcIPrdPCbSZRjcvzyXUnSRS.jpg",
      "adult": false,
      "overview": "In the DMZ separating North and South Korea, two North Korean soldiers have been killed, supposedly by one South Korean soldier. But the 11 bullets found in the bodies, together with the 5 remaining bullets in the assassin's magazine clip, amount to 16 bullets for a gun that should normally hold 15 bullets. The investigating Swiss/Swedish team from the neutral countries overseeing the DMZ suspects that another, unknown party was involved - all of which points to some sort of cover up. The truth is much simpler and much more tragic.",
      "poster_path": "/iTB01AX6We1h8CAJql55dUyvSWq.jpg",
      "popularity": 7.164
      }
      ],
      "total_pages": 5,
      "total_results": 95
      }
      """
    
    let data = json.data(using: .utf8)!
    let envelope = try! JSONDecoder().decode(MovieEnvelope.self, from: data)
    
    XCTAssertEqual(2, envelope.data.count)
    XCTAssertEqual(95, envelope.totalResults)
    XCTAssertEqual(5, envelope.totalPages)
    
    XCTAssertEqual("The Host", envelope.data[0].title)
    XCTAssertEqual("/iTB01AX6We1h8CAJql55dUyvSWq.jpg", envelope.data[1].posterPath)    
  }
}
