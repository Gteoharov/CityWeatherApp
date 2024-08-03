import Foundation

final class CitySearchItemsMapper {
    
    private init() {}
    
    private struct RootCitySearchResponse: Decodable {
        let data: [RemoteCitySearchItem]
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteCitySearchItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(RootCitySearchResponse.self, from: data) else {
            throw RemoteCitySearchLoader.Error.invalidData
        }
        return root.data
    }
}
