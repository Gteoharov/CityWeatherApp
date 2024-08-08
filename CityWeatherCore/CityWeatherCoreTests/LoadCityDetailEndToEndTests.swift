import XCTest
import CityWeatherCore

final class LoadCityDetailEndToEndTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        CityWeatherURLConfig.setTestBundle(Bundle(for: type(of: self)))
    }
    
    override func tearDown() {
        CityWeatherURLConfig.resetBundle()
        super.tearDown()
    }
}
