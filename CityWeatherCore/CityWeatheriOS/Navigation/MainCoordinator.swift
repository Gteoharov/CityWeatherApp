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
        let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteCityDetailLoader(request: URLRequest(url: CityWeatherURLConfig.detailCityBaseURL), client: client)
        let swiftUIView = DetailWeatherCityScreen(viewModel: CityDetailViewModel(loader: loader, lat: lat, lon: lon))
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}
