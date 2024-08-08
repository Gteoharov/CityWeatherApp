import XCTest
import CityWeatherCore

final class LoadCityDetailUseCaseTests: XCTestCase {
    
    
    func test_init_doesNotLoadDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.sentRequest, [])
    }
    
    func test_load_requestsDataFromURL() async {
        let (sut, client) = makeSUT(request: createURLRequest())
        
        let _ = await sut.load(2.33, lon: 22.22, units: .fahrenheit)
        
        XCTAssertEqual(client.sentRequest, [createURLRequest()])
    }
    
    func test_loadTwice_requestDataFromURL() async {
        let (sut, client) = makeSUT(request: createURLRequest())
        
        let _ = await sut.load(2.33, lon: 22.22, units: .fahrenheit)
        let _ = await sut.load(2.33, lon: 22.22, units: .fahrenheit)
        
        XCTAssertEqual(client.sentRequest, [createURLRequest(), createURLRequest()])
    }
    
    func test_load_deliversErrorOnHTTPClientError() async {
        let (sut, client) = makeSUT()
        
        client.stub(result: nil, error: anyNSError())
        
        let result = await sut.load(2.33, lon: 22.22, units: .fahrenheit)
        
        switch result {
        case let .failure(receivedError):
            XCTAssertEqual(receivedError as! RemoteCityDetailLoader.Error, RemoteCityDetailLoader.Error.noConnection)
            
        default:
            XCTFail("Expected failure, got \(result) instead")
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() async {
        let (sut, client) = makeSUT()
        
        let samples = createStatusCodesArray()
        
        samples.enumerated().forEach { index, code in
            client.stub(result: (statusCode: code, data: anyData()), error: nil)
            
            Task { [sut] in
                let result = await sut.load(2.33, lon: 22.22, units: .fahrenheit)
                
                switch result {
                case let .failure(receivedError):
                    XCTAssertEqual(receivedError as! RemoteCityDetailLoader.Error, RemoteCityDetailLoader.Error.invalidData)
                default:
                    XCTFail("Expected failure, but got \(result) instead")
                }
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
        let (sut, client) = makeSUT()
        
        client.stub(result: (statusCode: create200StatusCode(), data: anyData()), error: nil)
        
        let result = await sut.load(2.33, lon: 22.22, units: .fahrenheit)
        
        switch result {
        case let .failure(receivedError):
            XCTAssertEqual(receivedError as! RemoteCityDetailLoader.Error, RemoteCityDetailLoader.Error.invalidData)
        default:
            XCTFail("Expect failure, but got \(result) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(request: URLRequest = .init(url: anyURL()),
                         file: StaticString = #filePath,
                         line: UInt = #line
    ) -> (sut: RemoteCityDetailLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCityDetailLoader(request: request, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, client: client)
    }
    
    private func makeCityJSON(_ city: [String: Any]) -> Data {
        let json = city
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeCityDetailItem(
        coordinates: Coordinates = Coordinates(latitude: 0.0, longitude: 0.0),
        weather: [WeatherInfo] = [WeatherInfo(id: 0, main: "Clear", description: "clear sky", icon: "01d")],
        base: String = "stations",
        mainWeather: MainWeather = MainWeather(temp: 0.0, feels_like: 0.0, temp_min: 0.0, temp_max: 0.0, pressure: 1013, humidity: 0, sea_level: 1013, grnd_level: 1000),
        visibility: Int = 10000,
        windInfo: WindInfo = WindInfo(speed: 0.0, deg: 0, gust: nil),
        clouds: CloudsWeather = CloudsWeather(all: 0),
        dateTime: Int = 0,
        systemWeather: SystemWeather = SystemWeather(country: "US", sunrise: 0, sunset: 0),
        timezone: Int = 0,
        id: Int = 0,
        name: String = "City",
        cod: Int = 200
    ) -> (model: CityDetailItem, json: [String: Any]) {
        
        let cityDetailItem = CityDetailItem(
            coordinates: coordinates,
            weather: weather,
            base: base,
            mainWeather: mainWeather,
            visibility: visibility,
            windInfo: windInfo,
            clouds: clouds,
            dateTime: dateTime,
            systemWeather: systemWeather,
            timezone: timezone,
            id: id,
            name: name,
            cod: cod
        )
        
        var jsonCityDetail: [String: Any] = [
            "coord": [
                "lat": coordinates.latitude,
                "lon": coordinates.longitude
            ],
            "weather": weather.map { [
                "id": $0.id,
                "main": $0.main,
                "description": $0.description,
                "icon": $0.icon
            ] },
            "base": base,
            "main": [
                "temp": mainWeather.temp,
                "feels_like": mainWeather.feels_like,
                "temp_min": mainWeather.temp_min,
                "temp_max": mainWeather.temp_max,
                "pressure": mainWeather.pressure,
                "humidity": mainWeather.humidity,
                "sea_level": mainWeather.sea_level,
                "grnd_level": mainWeather.grnd_level
            ],
            "visibility": visibility,
            "clouds": [
                "all": clouds.all
            ],
            "dt": dateTime,
            "sys": [
                "country": systemWeather.country,
                "sunrise": systemWeather.sunrise,
                "sunset": systemWeather.sunset
            ],
            "timezone": timezone,
            "id": id,
            "name": name,
            "cod": cod
        ]
        
        
        var wind: [String: Any] = [
            "speed": windInfo.speed,
            "deg": windInfo.deg
        ]
        
        if let gust = windInfo.gust {
            wind["gust"] = gust
        }
        
        jsonCityDetail["wind"] = wind
        
        return (cityDetailItem, jsonCityDetail)
    }
}
