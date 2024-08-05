import Foundation

public protocol CitySearchLoader {
    typealias LoadCitySearchResult = Result<[CitySearchItem], Error>
    
    func load(withQuery: String) async -> LoadCitySearchResult
}
