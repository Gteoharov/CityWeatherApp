import UIKit
import Combine
import CityWeatherCore

public final class SearchCityViewController: UIViewController {
    
    private let viewModel: SearchCityViewModel
    
    private var subscriptions = Set<AnyCancellable>()
    
    weak var coordinator: MainCoordinator?
    
    private let searchController = UISearchController(searchResultsController: nil)
    public let tableView = UITableView()
    private let indicatorView = UIActivityIndicatorView(style: .medium)
    private let noResultsLabel = UILabel()
    private var temperatureButton = UIButton()
    
    public init(viewModel: SearchCityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUI()
    }
    
    private func bindViewModel() {
        Publishers.CombineLatest4(viewModel.$cityItems, viewModel.$isLoading, viewModel.$currentQuery, viewModel.$shouldTriggerSearch)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (items, isLoading, query, shouldTriggerSearch) in
                guard let self = self else { return }
                
                if shouldTriggerSearch {
                    self.tableView.reloadData()
                    
                    let shouldShowNoResults = !isLoading && items.isEmpty && query.count > 2
                    self.updateBackgroundView(isEmpty: items.isEmpty, showNoResults: shouldShowNoResults)
                    
                    if isLoading {
                        self.indicatorView.startAnimating()
                        self.noResultsLabel.isHidden = true
                    } else {
                        self.indicatorView.stopAnimating()
                        self.noResultsLabel.isHidden = !shouldShowNoResults
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$selectedTemperatureUnit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateTemperatureButtonTitle()
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let _ = self, let error = error else { return }
                // Handle error
                print("Error: \(error.localizedDescription)")
            }
            .store(in: &subscriptions)
            
    }
    
    private func updateBackgroundView(isEmpty: Bool, showNoResults: Bool) {
        tableView.backgroundView?.isHidden = !isEmpty
        noResultsLabel.isHidden = !showNoResults
    }
}

// MARK: - Helper methods
private extension SearchCityViewController {
    private func setUpUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "City Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        setupTableView()
        setupSearchController()
        setupBackgroundView()
        createNavBarButton()
    }
    
    private func createNavBarButton() {
        temperatureButton = UIButton(type: .system)
        temperatureButton.setTitle(viewModel.selectedTemperatureUnit.rawValue, for: .normal)
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        customView.addSubview(temperatureButton)
        
        temperatureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            temperatureButton.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            temperatureButton.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            temperatureButton.widthAnchor.constraint(equalTo: customView.widthAnchor),
            temperatureButton.heightAnchor.constraint(equalTo: customView.heightAnchor)
        ])
        
        let barButtonItem = UIBarButtonItem(customView: customView)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        updateMenu()
    }

    private func updateMenu() {
        let updatedMenu = UIMenu(title: "Select Temperature Unit", children: TemperatureUnit.allCases.map { unit in
            let state: UIMenuElement.State = (unit == viewModel.selectedTemperatureUnit) ? .on : .off
            return UIAction(title: unit.rawValue, state: state) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.changeTemperatureUnit(to: unit)
                self.updateTemperatureButtonTitle()
                self.updateMenu()
            }
        })
        
        temperatureButton.menu = updatedMenu
        temperatureButton.showsMenuAsPrimaryAction = true
    }
    
    private func updateTemperatureButtonTitle() {
        temperatureButton.setTitle(viewModel.selectedTemperatureUnit.rawValue, for: .normal)
    }
    
    private func setupTableView() {
        tableView.register(SearchCityTableViewCell.self, forCellReuseIdentifier: "SearchCityTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupBackgroundView() {
        let backgroundView = UIView()
        
        noResultsLabel.text = "No Cities Match Your Search"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .gray
        noResultsLabel.isHidden = true
        
        backgroundView.addSubview(indicatorView)
        backgroundView.addSubview(noResultsLabel)
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Constraints for indicatorView
            indicatorView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 75),
            indicatorView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            // Constraints for noResultsLabel
            noResultsLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 10),
            noResultsLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor)
        ])
        
        tableView.backgroundView = backgroundView
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Enter city name"
        searchController.searchBar.searchTextField.autocorrectionType = .no
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.delegate = self
        definesPresentationContext = true
    }
}

// MARK: - TableView Setup and Delegate/DataSource Methods
extension SearchCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCityTableViewCell", for: indexPath) as! SearchCityTableViewCell
        
        let city = viewModel.cityItems[indexPath.row]
        cell.configure(with: city)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.navigateToDetailWeatherCity(viewModel.cityItems[indexPath.row].latitude, lon: viewModel.cityItems[indexPath.row].longitude, unites: viewModel.selectedTemperatureUnit)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: -cell.frame.height)
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.75, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
            cell.transform = .identity
            cell.alpha = 1
        }, completion: nil)
    }
}

// MARK: - SearchBar Delegates
extension SearchCityViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.searchCity(query: query)
    }
}

extension SearchCityViewController: UISearchBarDelegate {
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.clearItems()
        tableView.reloadData()
    }
}

// MARK: - TextField Delegates
extension SearchCityViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty && range.length > 0 {
            viewModel.clearItems()
        }
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.clearItems()
        tableView.reloadData()
        return true
    }
}

extension SearchCityViewController {
    public func getSearchController() -> UISearchController {
        searchController
    }
    
    public func getTemperatureButton() -> UIButton {
        return temperatureButton
    }
    
    public func getTableView() -> UITableView {
        return tableView
    }
}
