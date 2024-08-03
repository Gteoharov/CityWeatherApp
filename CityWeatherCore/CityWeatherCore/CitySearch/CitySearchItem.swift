import Foundation

struct CitySearchItem: Equatable {
    public let name: String
    public let latitude: Double
    public let longitutde: Double
    public let country: String
    public let state: String?
    
    public init(name: String, latitude: Double, longitutde: Double, country: String, state: String?) {
        self.name = name
        self.latitude = latitude
        self.longitutde = longitutde
        self.country = country
        self.state = state
    }
}
