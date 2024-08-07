import SwiftUI
import Combine
import CityWeatherCore

struct DetailWeatherCityScreen: View {
    @ObservedObject var viewModel: CityDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let weatherResponse = viewModel.city {
                    WeatherInfoView(weatherResponse: weatherResponse)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 1), value: 10)
                } else {
                    Text("No weather data available")
                        .foregroundColor(.gray)
                }
            }
            .task {
                viewModel.fetchCityDetail()
            }
            
        }
        .refreshable {
            viewModel.fetchCityDetail()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Button action
                }) {
                    Image(systemName: "thermometer.high")
                }
            }
        }
    }
}

struct WeatherInfoView: View {
    let weatherResponse: CityDetailItem
    
    var body: some View {
        VStack {
            Text("\(Int(weatherResponse.mainWeather.temp))°")
                .font(.largeTitle)
                .bold()
            Text(weatherResponse.weather.first?.description ?? "")
                .font(.title2)
                .foregroundColor(.gray)
            if let icon = weatherResponse.weather.first?.icon {
                let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
                AsyncImage(url: iconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                }
            }
            Text(weatherResponse.name)
                .font(.title)
        }
    }
}

