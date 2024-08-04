import XCTest
import CityWeatherCore

final class LoadCitySearchUseCaseTests: XCTestCase {
    
    func test_init_doesNotLoadDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.sentRequest, [])
    }
    
    func test_load_requestsDataFromURL() async {
        let (sut, client) = makeSUT(request: createURLRequest())
        
        let _ = await sut.load(query: createQuery())
        
        XCTAssertEqual(client.sentRequest, [createURLRequest()])
    }
    
    func test_loadTwice_requestDataFromURL() async {
        let (sut, client) = makeSUT(request: createURLRequest())
        
        let _ = await sut.load(query: createQuery())
        let _ = await sut.load(query: createQuery())
        
        XCTAssertEqual(client.sentRequest, [createURLRequest(), createURLRequest()])
    }
    
    // MARK: - Sad paths
    
    func test_load_deliversErrorOnHTTPClientError() async {
        let (sut, client) = makeSUT()
        
        client.stub(result: nil, error: anyNSError())
        
        let result = await sut.load(query: createQuery())
        
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
                let result = await sut.load(query: createQuery())
                
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
        
        let result = await sut.load(query: createQuery())
        
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
        
        let result = await sut.load(query: createQuery())
        
        switch result {
        case let .success(receivedItems):
            XCTAssertEqual(receivedItems, [])
        default:
            XCTFail("Expected success, got \(result) instead")
        }
    }
    
    func test_load_deliversCitiesOn200HTTPResponseWithJSONItems() async {
        let(sut, client) = makeSUT()
        
        let firstCity = makeCity(name: "Paris", latitude: 23.33, longitude: 12.22, country: "France")
        let secondCity = makeCity(name: "Munich", latitude: 32.25, longitude: 1.23, country: "Germany", state: "Bayern")
        
        let itemsJSONData = makeCitiesJSON([firstCity.json, secondCity.json])
        
        client.stub(result: (statusCode: create200StatusCode(), data: itemsJSONData), error: nil)
        
        let result = await sut.load(query: createQuery())
        
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
                          latitude: Double,
                          longitude: Double,
                          country: String,
                          state: String? = nil) ->
    (model: CitySearchItem, json: [String: Any]) {
        let city = CitySearchItem(name: name, latitude: latitude, longitude: longitude, country: country, state: state)
        var jsonCity: [String: Any] = [
            "name": name,
            "lat": latitude,
            "lon": longitude,
            "country": country
        ]
        
        if let state = state {
            jsonCity["state"] = state
        }
        
        return (city, jsonCity)
    }
    
    private func makeCitiesJSON(_ cities: [[String: Any]]) -> Data {
        let json = cities
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        struct Stub {
            let result: (statusCode: Int, data: Data)?
            let error: Error?
        }
        
        private(set) var sentRequest = [URLRequest]()
        private(set) var stub: Stub?
        
        private let queue = DispatchQueue(label: "HTTPClientSpyQueue")
        
        func stub(result: (statusCode: Int, data: Data)?, error: Error?) {
            stub = Stub(result: result, error: error)
        }
        
        func perform(request: URLRequest, queryItems: [URLQueryItem]?) async -> HTTPClient.HTTPClientResult {
            queue.sync {
                sentRequest.append(request)
            }
            
            if let error = stub?.error {
                return .failure(error)
            }
            
            if let result = stub?.result {
                let response = HTTPURLResponse(url: request.url!, statusCode: result.statusCode, httpVersion: nil, headerFields: nil)!
                return .success((result.data, response))
            }
            
            return .failure(NSError(domain: "Empty error", code: 0))
        }
    }
}
