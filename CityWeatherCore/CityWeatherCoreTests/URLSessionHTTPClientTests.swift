import XCTest
import CityWeatherCore

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        StubUrlProtocol.startInterceptingRequests()
    }
    
    override func tearDown() {
        StubUrlProtocol.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_successful_request() async throws {
        let expectedData = "Success".data(using: .utf8)!
        StubUrlProtocol.stub(data: expectedData, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        
        let sut = makeSUT()
        let result = await sut.perform(request: URLRequest(url: anyURL()), queryItems: nil)
        
        switch result {
        case .success((let data, let response)):
            XCTAssertEqual(data, expectedData)
            XCTAssertEqual(response.statusCode, 200)
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }
    
    func test_failure_request() async throws {
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        StubUrlProtocol.stub(data: nil, response: nil, error: expectedError)
        
        let sut = makeSUT()
        let result = await sut.perform(request: URLRequest(url: anyURL()), queryItems: nil)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error as HTTPClientError):
            if case let .networkError(code, _) = error {
                XCTAssertEqual(code, expectedError.code)
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        default:
            XCTFail("Expected HTTPClientError")
        }
    }
    
    func test_different_statusCodes() async throws {
        let statusCodes = [200, 400, 500]
        
        for statusCode in statusCodes {
            StubUrlProtocol.stub(data: Data(), response: HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil), error: nil)
            
            let sut = makeSUT()
            let result = await sut.perform(request: URLRequest(url: anyURL()), queryItems: nil)
            
            switch result {
            case .success((_, let response)):
                XCTAssertEqual(response.statusCode, statusCode)
            case .failure:
                XCTFail("Expected success with status code \(statusCode), got failure")
            }
        }
    }
    
    func test_Query_Parameters() async throws {
        let expectation = XCTestExpectation(description: "Query parameters")
        
        StubUrlProtocol.observer = { request in
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            XCTAssertEqual(components?.queryItems?.count, 2)
            XCTAssertTrue(components?.queryItems?.contains(URLQueryItem(name: "key1", value: "value1")) ?? false)
            XCTAssertTrue(components?.queryItems?.contains(URLQueryItem(name: "key2", value: "value2")) ?? false)
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil), Data())
        }
        
        let sut = makeSUT()
        let queryItems = [URLQueryItem(name: "key1", value: "value1"), URLQueryItem(name: "key2", value: "value2")]
        _ = await sut.perform(request: URLRequest(url: anyURL()), queryItems: queryItems)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func test_getFromURL_performsGETRequestsWithURL() async throws {
        let url = URL(string: "https://any-url.com")!
        let expectation = expectation(description: "Wait for request")
        
        StubUrlProtocol.observer = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
            return (HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), Data())
        }
        
        let sut = makeSUT()
        _ = await sut.perform(request: URLRequest(url: url), queryItems: nil)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubUrlProtocol.self]
        let session = URLSession(configuration: configuration)
        return URLSessionClient(session: session)
    }
    
    private class StubUrlProtocol: URLProtocol {
        private static var stub: (data: Data?, response: URLResponse?, error: Error?)?
        static var observer: ((URLRequest) -> (URLResponse?, Data?))?
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(StubUrlProtocol.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(StubUrlProtocol.self)
            stub = nil
            observer = nil
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = (data, response, error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let observer = Self.observer {
                let (response, data) = observer(request)
                if let response = response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
            } else if let stub = Self.stub {
                if let error = stub.error {
                    client?.urlProtocol(self, didFailWithError: error)
                } else {
                    if let response = stub.response {
                        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    }
                    if let data = stub.data {
                        client?.urlProtocol(self, didLoad: data)
                    }
                }
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
