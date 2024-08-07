import Foundation

public protocol CityDetailLoader {
    typealias LoadCityDetailResult = Result<CityDetailItem, Error>
    
    func load(_ lat: Double, lon: Double, units: TemperatureUnit) async -> LoadCityDetailResult
}
