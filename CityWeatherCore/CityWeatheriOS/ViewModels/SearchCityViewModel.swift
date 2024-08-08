import Combine
import CityWeatherCore

public final class SearchCityViewModel {
    private let loader: CitySearchLoader
    private var subscriptions = Set<AnyCancellable>()
    
    @Published private(set) var cityItems: [CitySearchItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var selectedTemperatureUnit: TemperatureUnit = .fahrenheit
    @Published private(set) var error: Error?
    @Published private(set) var currentQuery = ""
    @Published private(set) var lastSuccessfulQuery = ""
    @Published private(set) var shouldTriggerSearch = false
    
    private let searchSubject = PassthroughSubject<String, Never>()
    
    init(loader: CitySearchLoader) {
        self.loader = loader
        setupBindings()
    }
    
    func searchCity(query: String) {
        currentQuery = query
        if query != lastSuccessfulQuery {
            shouldTriggerSearch = true
            searchSubject.send(query)
        } else {
            shouldTriggerSearch = false
        }
    }
    
    private func setupBindings() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self, query.count > 2 else {
                    self?.clearItems()
                    return
                }
                self.fetchCityItems(query: query)
            }
            .store(in: &subscriptions)
    }
    
    private func fetchCityItems(query: String) {
        guard query != lastSuccessfulQuery else { return }
        
        isLoading = true
        
        Task {
            let result = await loader.load(withQuery: query)
            
            self.isLoading = false
            switch result {
            case .success(let items):
                self.cityItems = items
                self.lastSuccessfulQuery = query
                self.error = nil
            case .failure(let error):
                self.cityItems = []
                self.error = error
            }
            self.shouldTriggerSearch = false
        }
    }
    
    func clearItems() {
        cityItems = []
        lastSuccessfulQuery = ""
        currentQuery = ""
        shouldTriggerSearch = false
    }
    
    func changeTemperatureUnit(to unit: TemperatureUnit) {
        selectedTemperatureUnit = unit
    }
    
    func displayName(_ index: Int) -> String {
        cityItems[index].name
    }
    
    func rowsCount() -> Int {
        cityItems.count
    }
    
    func getCity(at index: Int) -> CitySearchItem {
        return cityItems[index]
    }
}
