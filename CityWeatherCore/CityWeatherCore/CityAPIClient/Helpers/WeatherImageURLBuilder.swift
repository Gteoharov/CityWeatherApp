import Foundation

public struct WeatherImageURLBuilder {
    static func weatherIconURL(iconCode: String) -> URL {
        let baseURL = "https://openweathermap.org/img/wn/"
        guard let url = URL(string: "\(baseURL)\(iconCode)@2x.png") else {
            fatalError("Invalid URL construction with icon code: \(iconCode)")
        }
        return url
    }
}
