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
    
    func test_load_deliversCityOn200HTTPResponseWithJSONItem() async {
        let(sut, client) = makeSUT()
        
        let city = makeCityDetailItem(coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194), name: "San Francisco")
        
        let itemsJSONData = makeCityJSON(city.json)
        
        client.stub(result: (statusCode: create200StatusCode(), data: itemsJSONData), error: nil)
        
        let result = await sut.load(37.7749, lon: -122.4194, units: .fahrenheit)
        
        switch result {
        case let .success(receivedItems):
            XCTAssertEqual(receivedItems, city.model)
            
        default:
            XCTFail("Expect success, got \(result) instead")
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
}
