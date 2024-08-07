import Foundation

struct RemoteCitySearchItem: Decodable {
    let name: String
    let local_names: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}
