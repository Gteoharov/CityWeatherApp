import XCTest
import CityWeatheriOS
import CityWeatherCore

final class CityWeatheriOSTests: XCTestCase {
    
    
    
    
    // MARK: - Helpers
    
    private class CitiesSearchLoaderSpy: CitySearchLoader {
        private(set) var loadCallCount: Int = 0
        
        private let responseContinuation: AsyncStream<Result<[CitySearchItem], Error>>.Continuation
        private let responseStream: AsyncStream<Result<[CitySearchItem], Error>>
        
        private(set) var loadCompletion: (() -> Void)?
        
        init() {
            var responseContinuation: AsyncStream<Result<[CitySearchItem], Error>>.Continuation!
            self.responseStream = AsyncStream { responseContinuation = $0 }
            self.responseContinuation = responseContinuation
            
            self.responseContinuation.onTermination = { @Sendable _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.loadCompletion?()
                }
            }
        }
        func load(withQuery: String) async -> LoadCitySearchResult {
            loadCallCount += 1
            
            let result = await responseStream.first(where: { _ in true })!
            responseContinuation.finish()
            
            return result
        }
        
        func complete(with sports: [CitySearchItem] = [], completion: @escaping (() -> Void)) {
            loadCompletion = completion
            responseContinuation.yield(.success(sports))
        }
        
        func complete(with error: Error, completion: @escaping (() -> Void)) {
            loadCompletion = completion
            responseContinuation.yield(.failure(error))
        }
    }
}


private extension SearchCityViewController {
    func numberOfRenderedCities() -> Int {
        tableView.numberOfRows(inSection: 0)
    }
    
    func cell(for row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: row, section: 0)
        
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
}

private extension SearchCityTableViewCell {
    var name: String? {
        cityLabel.text
    }
}

