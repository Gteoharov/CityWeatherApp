import Foundation

public struct CityWeatherURLConfig {
    private static var testBundle: Bundle?

    private static var bundle: Bundle {
        return testBundle ?? Bundle.main
    }

    public static var searchBaseURL: URL {
        guard let urlString = bundle.infoDictionary?["SearchBaseURL"] as? String, let url = URL(string: urlString) else {
            fatalError("Base URL not configured correctly")
        }
        return url
    }
    
    public static var detailCityBaseURL: URL {
        guard let urlString = bundle.infoDictionary?["CityDetailBaseURL"] as? String, let url = URL(string: urlString) else {
            fatalError("Base URL not configured correctly")
        }
        return url
    }
    
    public static func setTestBundle(_ bundle: Bundle) {
        self.testBundle = bundle
    }
    
    public static func resetBundle() {
        self.testBundle = nil
    }
}
