import Foundation

final class CityDetailItemsMapper {
    
    private init() {}
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteCityDetailItem {
        guard response.statusCode == 200 else {
            throw RemoteCityDetailLoader.Error.invalidData
        }
        
        do {
            let city = try JSONDecoder().decode(RemoteCityDetailItem.self, from: data)
            return city
        } catch {
            print("Decoding error: \(error)")
            throw RemoteCityDetailLoader.Error.invalidData
        }
    }
}
