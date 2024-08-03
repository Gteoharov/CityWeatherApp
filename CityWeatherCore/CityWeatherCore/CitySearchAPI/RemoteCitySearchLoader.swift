import Foundation

public final class RemoteCitySearchLoader: CitySearchLoader {
    private let request: URLRequest
    private let client: HTTPClient
    
    public init(request: URLRequest, client: HTTPClient) {
        self.request = request
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    private enum QueryParameter {
        // query param for search City
        static let city = "q"
    }
    
    private func buildSearchQuery(for query: String) -> [URLQueryItem] {
        [URLQueryItem(name: QueryParameter.city, value: query)]
    }
    
    
    public func load(query: String) async -> CitySearchLoader.LoadCitySearchResult {
        let result = await client.perform(request: request, queryItems: buildSearchQuery(for: query))
        
        switch result {
        case let .success((data, response)):
            do {
                let cities = try CitySearchItemsMapper.map(data, from: response)
                return .success(cities.toModels())
            } catch {
                return .failure(error)
            }
        case .failure:
            return .failure(Error.noConnection)
        }
    }
}

private extension Array where Element == RemoteCitySearchItem {
    func toModels() -> [CitySearchItem] {
        map { CitySearchItem(name: $0.name, latitude: $0.lat, longitude: $0.lon, country: $0.country, state: $0.state) }
    }
}
