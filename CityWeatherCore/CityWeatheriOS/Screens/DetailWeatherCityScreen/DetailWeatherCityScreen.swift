import SwiftUI
import Combine

struct DetailWeatherCityScreen: View {
    @ObservedObject var viewModel: CityDetailViewModel
    
    var body: some View {
        ScrollView {
            content
                .animation(.easeInOut(duration: 0.5), value: viewModel.city)
        }
        .task {
            viewModel.fetchCityDetail()
        }
        .refreshable {
            viewModel.fetchCityDetail()
        }
        .errorAlert(for: $viewModel.error)
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let cityDetail = viewModel.city {
            WeatherDetailView(cityDetail: cityDetail)
        } else {
            Text("No weather data available")
                .foregroundColor(.gray)
        }
    }
}
