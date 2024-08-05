import UIKit
import SwiftUI
import CityWeatherCore

public class MainCoordinator: Coordinator {
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func configureRootScreen() {
        
    }
}
