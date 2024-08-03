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
    
    // MARK: - Helpers
    
    private func makeSUT(request: URLRequest = .init(url: URL(string: "https://a-url.com")!), 
                         file: StaticString = #filePath,
                         line: UInt = #line
    ) -> (sut: RemoteCitySearchLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCitySearchLoader(request: request, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, client: client)
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
