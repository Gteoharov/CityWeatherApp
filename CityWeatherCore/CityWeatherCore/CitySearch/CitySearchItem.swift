import Foundation

public struct CitySearchItem: Equatable {
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let country: String
    public let state: String?
    
    public init(name: String, latitude: Double, longitude: Double, country: String, state: String?) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.state = state
    }
}
