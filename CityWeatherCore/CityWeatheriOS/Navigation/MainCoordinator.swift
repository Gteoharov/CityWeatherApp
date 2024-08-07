import UIKit
import SwiftUI
import CityWeatherCore

public class MainCoordinator: Coordinator {
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func configureRootScreen() {
        let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
        let request = URLRequest(url: CityWeatherURLConfig.searchBaseURL)
        let loader = RemoteCitySearchLoader(request: request, client: client)
        let viewModel = SearchCityViewModel(loader: loader)
        let searchCityVC = SearchCityViewController(viewModel: viewModel)
        searchCityVC.coordinator = self
        
        navigationController.pushViewController(searchCityVC, animated: false)
    } 
    
    public func navigateToDetailWeatherCity(_ lat: Double, lon: Double) {
        let parameters = [
            "units": "metric",
            "appid": "86879ac16cba5e431ae293fa564b6bf3"
        ]

        // Create URLComponents from the base URL
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalURL = urlComponents?.url else {
            return
        }
        let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteCityDetailLoader(request: URLRequest(url: finalURL), client: client)
        let swiftUIView = DetailWeatherCityScreen(viewModel: CityDetailViewModel(loader: loader, lat: lat, lon: lon))
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}
