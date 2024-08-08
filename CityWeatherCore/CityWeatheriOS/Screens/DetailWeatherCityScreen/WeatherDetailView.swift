import SwiftUI
import CityWeatherCore

struct WeatherDetailView: View {
    let cityDetail: CityDetailItem
    
    var body: some View {
        VStack(spacing: 20) {
            temperatureView
            weatherDescriptionView
            weatherIconView
            cityNameView
        }
        .padding(.top)
        .transition(.opacity)
    }
    
    private var temperatureView: some View {
        Text(String(format: "%.1f°", cityDetail.mainWeather.temp))
            .font(.largeTitle)
            .bold()
    }
    
    private var weatherDescriptionView: some View {
        Text(cityDetail.weather[0].description)
            .font(.title2)
            .foregroundColor(.gray)
    }
    
    private var weatherIconView: some View {
        AsyncImage(url: cityDetail.weatherIcon) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        } placeholder: {
            ProgressView()
        }
    }
    
    private var cityNameView: some View {
        Text(cityDetail.name)
            .font(.title)
    }
}
