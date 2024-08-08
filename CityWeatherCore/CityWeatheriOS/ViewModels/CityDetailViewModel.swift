import Combine
import CityWeatherCore

class CityDetailViewModel: ObservableObject {
    
    private let loader: CityDetailLoader
    private let lat: Double
    private let lon: Double
    private let unites: TemperatureUnit
    
    @Published private(set) var city: CityDetailItem?
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    
    init(loader: CityDetailLoader, lat: Double, lon: Double, unites: TemperatureUnit) {
        self.loader = loader
        self.lat = lat
        self.lon = lon
        self.unites = unites
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    func fetchCityDetail() {
        isLoading = true
        
        Future<CityDetailItem, Error> { [weak self] promise in
            guard let self = self else { return }
            Task {
                let result = await self.loader.load(self.lat, lon: self.lon, units: self.unites)
                promise(result)
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
            case .failure(let error):
                self.error = error
                self.city = nil
            case .finished:
                break
            }
        }, receiveValue: { [weak self] city in
            guard let self = self else { return }
            self.city = city
            self.error = nil
            
        })
        .store(in: &subscriptions)
    }
}
