import Foundation

public struct CityWeatherURLConfig {
    public static var searchBaseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SearchBaseURL"] as? String, let url = URL(string: urlString) else {
            fatalError("Base URL not configured correctly")
        }
        return url
    }
}
