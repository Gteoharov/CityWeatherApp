import SwiftUI
import Combine

class CityDetailViewModel: ObservableObject {
    @Published var weatherResponse: WeatherResponse?
    @Published var isLoading = false
    @Published var weatherIcon: UIImage?
    
    private let lat: Double
    private let lon: Double
    
    init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let cache = NSCache<NSString, UIImage>()
    
    func fetchWeather() {
        isLoading = true
        
        let apiKey = "86879ac16cba5e431ae293fa564b6bf3"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?units=metric&lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] weatherResponse in
                self?.weatherResponse = weatherResponse
                if let icon = weatherResponse.weather.first?.icon {
                    self?.fetchWeatherIcon(icon: icon)
                }
            })
            .store(in: &cancellables)
    }
    
    private func fetchWeatherIcon(icon: String) {
        let iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        
        if let cachedImage = cache.object(forKey: iconURL as NSString) {
            self.weatherIcon = cachedImage
            return
        }
        
        guard let url = URL(string: iconURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.cache.setObject(image, forKey: iconURL as NSString)
                self?.weatherIcon = image
            }
        }.resume()
    }
}
