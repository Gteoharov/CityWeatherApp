import SwiftUI
import Combine


struct DetailWeatherCityScreen: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let weatherResponse = viewModel.weatherResponse {
                    WeatherInfoView(weatherResponse: weatherResponse, weatherIcon: viewModel.weatherIcon)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: 10)
                } else {
                    Text("No weather data available")
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                viewModel.fetchWeather()
            }
            .refreshable {
                viewModel.fetchWeather()
            }
        }
    }
}

struct WeatherInfoView: View {
    let weatherResponse: WeatherResponse
    let weatherIcon: UIImage?
    
    var body: some View {
        VStack {
            Text("\(Int(weatherResponse.main?.temp ?? 0 - 273.15))°")
                .font(.largeTitle)
                .bold()
            Text(weatherResponse.weather?.first?.description ?? "")
                .font(.title2)
                .foregroundColor(.gray)
            if let icon = weatherIcon {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            Text(weatherResponse.name ?? "")
                .font(.title)
        }
    }
}



class WeatherViewModel: ObservableObject {
    @Published var weatherResponse: WeatherResponse?
    @Published var isLoading = false
    @Published var weatherIcon: UIImage?
    
    private let city: String
    
    init(city: String) {
        self.city = city
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let cache = NSCache<NSString, UIImage>()
    
    func fetchWeather() {
        isLoading = true
        
        let apiKey = "86879ac16cba5e431ae293fa564b6bf3"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)"
        
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
                if let icon = weatherResponse.weather?.first?.icon {
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



struct WeatherResponse: Codable {
    let coord: Coord?
    let weather: [Weather]?
    let main: Main?
    let wind: Wind?
    let sys: Sys?
    let name: String?
    
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
    
    struct Weather: Codable, Identifiable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Int
        let humidity: Int
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    
    struct Sys: Codable {
        let country: String
        let sunrise: Int
        let sunset: Int
    }
}

