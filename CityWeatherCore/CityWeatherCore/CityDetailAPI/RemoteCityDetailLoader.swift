import Foundation

public final class RemoteCityDetailLoader: CityDetailLoader {
    
    
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
        // query params for lat and lon of City
        static let lat = "lat"
        static let lon = "lon"
    }
    
    private func buildDetailQuery(lat: Double, lon: Double) -> [URLQueryItem] {
        [
            URLQueryItem(name: QueryParameter.lat, value: "\(lat)"),
            URLQueryItem(name: QueryParameter.lon, value: "\(lon)"),
        ]
    }
    
    public func load(_ lat: Double, lon: Double) async -> RemoteCityDetailLoader.LoadCityDetailResult {
        
        let result = await client.perform(request: request, queryItems: buildDetailQuery(lat: lat, lon: lon))
        
        switch result {
        case let .success((data, response)):
            do {
                let city = try CityDetailItemsMapper.map(data, from: response)
                return .success(city.toModel())
            } catch {
                return .failure(error)
            }
        case .failure:
            return .failure(Error.noConnection)
        }
    }
}

private extension RemoteCityDetailItem {
    func toModel() -> CityDetailItem {
        CityDetailItem(coordinates: self.cord.toModel(), weather: self.weather.toModels(), base: self.base, mainWeather: self.main.toModel(), visibility: self.visibility, windInfo: self.wind.toModel(), clouds: self.clouds.toModel(), dateTime: self.dt, systemWeather: self.sys.toModel(), timezone: self.timezone, id: self.id, name: self.name, code: self.code)
    }
}

private extension Coord {
    func toModel() -> Coordinates {
        Coordinates(latitude: self.lat, longitude: self.lon)
    }
}

private extension Array where Element == Weather {
    func toModels() -> [WeatherInfo] {
        map { WeatherInfo(id: $0.id, main: $0.main, description: $0.description, icon: $0.icon)
        }
    }
}

private extension Main {
    func toModel() -> MainWeather {
        MainWeather(temp: self.temp, feels_like: self.feels_like, temp_min: self.temp_min, temp_max: self.temp_max, pressure: self.pressure, humidity: self.humidity, sea_level: self.sea_level, grnd_level: self.grnd_level)
    }
}

private extension Wind {
    func toModel() -> WindInfo {
        WindInfo(speed: self.speed, deg: self.deg, gust: self.gust)
    }
}

private extension Clouds {
    func toModel() -> CloudsWeather {
        CloudsWeather(all: self.all)
    }
}

private extension Sys {
    func toModel() -> SystemWeather {
        SystemWeather(country: self.country, sunrise: self.sunrise, sunset: self.sunset)
    }
}






