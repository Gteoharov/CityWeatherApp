import XCTest
import CityWeatherCore

final class LoadCitySearchUseCaseTests: XCTestCase {
    
    func test_init_doesNotLoadDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.sentRequest, [])
    }
    
    func test_load_requestsDataFromURL() async {
        let (sut, client) = makeSUT(request: createURLRequest())
        
        let _ = await sut.load(withQuery: createQuery())
        
        XCTAssertEqual(client.sentRequest, [createURLRequest()])
    }
    
    func test_loadTwice_requestDataFromURL() async {
        let (sut, client) = makeSUT(request: createURLRequest())
        
        let _ = await sut.load(withQuery: createQuery())
        let _ = await sut.load(withQuery: createQuery())
        
        XCTAssertEqual(client.sentRequest, [createURLRequest(), createURLRequest()])
    }
    
    // MARK: - Sad paths
    
    func test_load_deliversErrorOnHTTPClientError() async {
        let (sut, client) = makeSUT()
        
        client.stub(result: nil, error: anyNSError())
        
        let result = await sut.load(withQuery: createQuery())
        
        switch result {
        case let .failure(receivedError):
            XCTAssertEqual(receivedError as! RemoteCitySearchLoader.Error, RemoteCitySearchLoader.Error.noConnection)
            
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
                let result = await sut.load(withQuery: createQuery())
                
                switch result {
                case let .failure(receivedError):
                    XCTAssertEqual(receivedError as! RemoteCitySearchLoader.Error, RemoteCitySearchLoader.Error.invalidData)
                default:
                    XCTFail("Expected failure, but got \(result) instead")
                }
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
        let (sut, client) = makeSUT()
        
        client.stub(result: (statusCode: create200StatusCode(), data: anyData()), error: nil)
        
        let result = await sut.load(withQuery: createQuery())
        
        switch result {
        case let .failure(receivedError):
            XCTAssertEqual(receivedError as! RemoteCitySearchLoader.Error, RemoteCitySearchLoader.Error.invalidData)
        default:
            XCTFail("Expect failure, but got \(result) instead")
        }
    }
    
    // MARK: - Happy paths
    
    func test_load_deliversNoCitiesOn200HTTPResponseWithEmptyJSONList() async {
        let (sut, client) = makeSUT()
        
        client.stub(result: (statusCode: create200StatusCode(), data: createEmptyListJSONData()), error: nil)
        
        let result = await sut.load(withQuery: createQuery())
        
        switch result {
        case let .success(receivedItems):
            XCTAssertEqual(receivedItems, [])
        default:
            XCTFail("Expected success, got \(result) instead")
        }
    }
    
    func test_load_deliversCitiesOn200HTTPResponseWithJSONItems() async {
        let(sut, client) = makeSUT()
        
        let firstCity = makeCity(name: "Paris", localNames: [:], latitude: 23.33, longitude: 12.22, country: "France")
        let secondCity = makeCity(name: "Munich", localNames: [:], latitude: 32.25, longitude: 1.23, country: "Germany", state: "Bayern")
        
        let itemsJSONData = makeCitiesJSON([firstCity.json, secondCity.json])
        
        client.stub(result: (statusCode: create200StatusCode(), data: itemsJSONData), error: nil)
        
        let result = await sut.load(withQuery: createQuery())
        
        switch result {
        case let .success(receivedItems):
            XCTAssertEqual(receivedItems, [firstCity.model, secondCity.model])
            
        default:
            XCTFail("Expect success, got \(result) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(request: URLRequest = .init(url: anyURL()),
                         file: StaticString = #filePath,
                         line: UInt = #line
    ) -> (sut: RemoteCitySearchLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCitySearchLoader(request: request, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, client: client)
    }
    
    private func makeCity(name: String,
                          localNames: [String: String]? = nil,
                          latitude: Double,
                          longitude: Double,
                          country: String,
                          state: String? = nil) ->
    (model: CitySearchItem, json: [String: Any]) {
        let city = CitySearchItem(name: name, localNames: localNames, latitude: latitude, longitude: longitude, country: country, state: state)
        var jsonCity: [String: Any] = [
            "name": name,
            "lat": latitude,
            "lon": longitude,
            "country": country
        ]
        
        if let localNames = localNames {
            jsonCity["local_names"] = localNames
        }
        
        if let state = state {
            jsonCity["state"] = state
        }
        
        return (city, jsonCity)
    }
    
    private func makeCitiesJSON(_ cities: [[String: Any]]) -> Data {
        let json = cities
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
