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
