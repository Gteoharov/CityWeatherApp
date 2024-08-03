import Foundation

public protocol CitySearchLoader {
    typealias LoadCitySearchResult = Result<[CitySearchItem], Error>
    
    func load(query: String) async -> LoadCitySearchResult
}
