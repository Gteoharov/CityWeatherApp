import XCTest
import CityWeatherCore

final class LoadCityDetailUseCaseTests: XCTestCase {
    
    
    func test_init_doesNotLoadDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.sentRequest, [])
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
