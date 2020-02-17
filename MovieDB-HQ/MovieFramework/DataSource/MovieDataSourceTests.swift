@testable import MovieFramework
@testable import MovieLibrary
@testable import MovieApi
import XCTest

final class MoviesDataSourceTests: XCTestCase {
  let dataSource = MovieDataSource()
  let tableView = UITableView()
  
  func testSurvey() {
    let section = MovieDataSource.Section.Movie.rawValue
    
    self.dataSource.load(movies: [.template])
    
    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
    XCTAssertEqual("MovieCell", self.dataSource.reusableId(item: 0, section: section))
    
    self.dataSource.load(movies: [])
    
    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
  }
}
