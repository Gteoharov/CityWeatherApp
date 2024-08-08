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
    
    func test_endToEndTestServerGETCityDetailResult_matchesFixedTestData() async {
        let testServerURL = CityWeatherURLConfig.detailCityBaseURL
        let expectedCity = makeCityDetailItem()
        
        let urlRequest = URLRequest(url: testServerURL)
        let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteCityDetailLoader(request: urlRequest, client: client)
        
        let receivedResult: RemoteCityDetailLoader.LoadCityDetailResult = await loader.load(25.6419, lon: 42.4328, units: .fahrenheit)
        
        switch receivedResult {
        case let .success(receivedCity):
            XCTAssertEqual(receivedCity.coordinates, expectedCity.model.coordinates)
        case let .failure(error):
            XCTFail("Expected successful city result, got \(error) instead.")
        }
    }
}
