import Foundation

public struct MovieEnvelope {
  public var data: [Movie]
  public var page: Int
  public var totalPages: Int
  public var totalResults: Int
}

extension MovieEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case data = "results", page, totalPages = "total_pages", totalResults = "total_results"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try values.decode([Movie].self, forKey: .data)
    self.page = try values.decode(Int.self, forKey: .page)
    self.totalPages = try values.decode(Int.self, forKey: .totalPages)
    self.totalResults = try values.decode(Int.self, forKey: .totalResults)
  }
}

public struct Movie {
  public var id: Int?
  public var posterPath: String?
  public var title: String?
  public var releaseDate: String?
  public var overview: String?
}

extension Movie: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case id, posterPath = "poster_path", title, releaseDate = "release_date", overview
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try values.decodeIfPresent(Int.self, forKey: .id)
    self.posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
    self.title = try values.decodeIfPresent(String.self, forKey: .title)
    self.releaseDate = try values.decodeIfPresent(String.self, forKey: .releaseDate)
    self.overview = try values.decodeIfPresent(String.self, forKey: .overview)
  }
}

extension Movie: Equatable {}
