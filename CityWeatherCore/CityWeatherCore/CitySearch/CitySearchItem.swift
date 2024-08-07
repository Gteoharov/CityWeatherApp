import Foundation

public struct CitySearchItem: Equatable {
    public let name: String
    public let localNames: [String: String]?
    public let latitude: Double
    public let longitude: Double
    public let country: String
    public let state: String?
    
    public init(name: String, localNames: [String: String]?, latitude: Double, longitude: Double, country: String, state: String?) {
        self.name = name
        self.localNames = localNames
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.state = state
    }
}
