import Foundation

final class CitySearchItemsMapper {
    
    private init() {}
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteCitySearchItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteCitySearchLoader.Error.invalidData
        }
        
        do {
            let cities = try JSONDecoder().decode([RemoteCitySearchItem].self, from: data)
            return cities
        } catch {
            print("Decoding error: \(error)")
            throw RemoteCitySearchLoader.Error.invalidData
        }
    }
}
