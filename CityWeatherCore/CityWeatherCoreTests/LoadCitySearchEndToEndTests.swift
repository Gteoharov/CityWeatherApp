import XCTest
import CityWeatherCore

final class LoadCitySearchEndToEndTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        CityWeatherURLConfig.setTestBundle(Bundle(for: type(of: self)))
    }
    
    override func tearDown() {
        CityWeatherURLConfig.resetBundle()
        super.tearDown()
    }
    
    func test_endToEndTestServerGETCitySearchResult_matchesFixedTestData() async {
        let testServerURL = CityWeatherURLConfig.searchBaseURL
        let expectedCities = [
            CitySearchItem(name: "Par", localNames: nil, latitude: 50.3494152, longitude: -4.7050945, country: "GB", state: "England"),
            CitySearchItem(name: "Par", localNames: ["en" : "Par", "fa" : "پر"], latitude: 37.6809622, longitude: 45.0113965, country: "IR", state: "West Azerbaijan Province"),
            CitySearchItem(name: "Parada", localNames: nil, latitude: 42.0222724, longitude: -8.0337175, country: "ES", state: "Galicia"),
            CitySearchItem(name: "Parada", localNames: nil, latitude: 43.0654638, longitude: -7.6485272, country: "ES", state: "Galicia"),
            CitySearchItem(name: "Parada", localNames: nil, latitude: 43.076012500000004, longitude: -8.450996357074423, country: "ES", state: "Galicia")
        ]
        
        var urlRequest = URLRequest(url: testServerURL)
        let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteCitySearchLoader(request: urlRequest, client: client)
        
        let receivedResult: RemoteCitySearchLoader.LoadCitySearchResult = await loader.load(withQuery: "par")
        
        switch receivedResult {
        case let .success(receivedCities):
            XCTAssertFalse(receivedCities.isEmpty, "Expected sports to not be empty in the test catalogue.")
            XCTAssertEqual(receivedCities, expectedCities)
        case let .failure(error):
            XCTFail("Expected successful sports result, got \(error) instead.")
        }
    }
}
