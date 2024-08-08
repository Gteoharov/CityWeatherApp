import Foundation
import CityWeatherCore

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func createEmptyListJSONData() -> Data {
    Data("[]".utf8)
}

func createURLRequest() -> URLRequest {
    URLRequest(url: anyURL())
}

func createURLQuerryItemArray(for query: String) -> [URLQueryItem] {
    [URLQueryItem(name: "k", value: query)]
}

func create200StatusCode() -> Int {
    200
}

func createStatusCodesArray() -> [Int] {
    [199, 201, 300, 400, 500]
}

func createQuery() -> String {
    "Paris"
}

func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func buildURL(with query: String, url: URL) -> URL {
    url.appending(queryItems: [URLQueryItem(name: "q", value: query)])
}

func makeCityJSON(_ city: [String: Any]) -> Data {
    let json = city
    return try! JSONSerialization.data(withJSONObject: json)
}

func makeCityDetailItem(
    coordinates: Coordinates = Coordinates(latitude: 25.6419, longitude: 42.4328),
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
    name: String = "Stara Zagora",
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

