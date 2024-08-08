import XCTest
import CityWeatheriOS
import CityWeatherCore

final class CityWeatheriOSTests: XCTestCase {
    
    func test_init_doesNotLoadCities() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewController_hasTableView() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.viewWillAppear(false) // This will call setUpUI()
        
        XCTAssertNotNil(sut.getTableView(), "The tableView should be not nil.")
    }
    
    func test_viewController_hasSearchController() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.viewWillAppear(false)

        XCTAssertNotNil(sut.navigationItem.searchController, "The searchController should be set in the navigation item.")
        XCTAssertEqual(sut.navigationItem.searchController, sut.getSearchController(), "The searchController should be the one set up in the view controller.")
    }
    
    func test_viewController_hasNavigationBarButton() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.viewWillAppear(false)

        let rightBarButtonItem = sut.navigationItem.rightBarButtonItem
        XCTAssertNotNil(rightBarButtonItem, "The navigation bar button should be set.")
        XCTAssertTrue(rightBarButtonItem?.customView is UIView, "The right bar button item should have a custom view.")
        XCTAssertEqual(rightBarButtonItem?.customView?.subviews.first as? UIButton, sut.getTemperatureButton(), "The custom view should contain the temperature button.")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (SearchCityViewController, CitiesSearchLoaderSpy) {
        let loader = CitiesSearchLoaderSpy()
        let viewModel = SearchCityViewModel(loader: loader)
        let sut =  SearchCityViewController(viewModel: viewModel)
        
        return (sut, loader)
    }
    
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
        
        func complete(with cities: [CitySearchItem] = [], completion: @escaping (() -> Void)) {
            loadCompletion = completion
            responseContinuation.yield(.success(cities))
        }
        
        func complete(with error: Error, completion: @escaping (() -> Void)) {
            loadCompletion = completion
            responseContinuation.yield(.failure(error))
        }
    }
}
