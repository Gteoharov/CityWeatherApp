import SwiftUI
import Combine
struct DetailWeatherCityScreen: View {
    @ObservedObject var viewModel: CityDetailViewModel
    
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
            Text("\(Int(weatherResponse.main.temp))°")
                .font(.largeTitle)
                .bold()
            Text(weatherResponse.weather.first?.description ?? "")
                .font(.title2)
                .foregroundColor(.gray)
            if let icon = weatherIcon {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            Text(weatherResponse.name)
                .font(.title)
        }
    }
}







struct WeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let sys: Sys
    let name: String
    
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

