import UIKit
import Combine
import CityWeatherCore

final class SearchCityViewController: UIViewController {
    
    private let viewModel: SearchCityViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    weak var coordinator: MainCoordinator?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let indicatorView = UIActivityIndicatorView(style: .medium)
    private let noResultsLabel = UILabel()
    
    public init(viewModel: SearchCityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        let stackView = UIStackView(arrangedSubviews: [indicatorView, noResultsLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        
        backgroundView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 75),
            stackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -20)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCityTableViewCell", for: indexPath) as! SearchCityTableViewCell
        
        let city = viewModel.cityItems[indexPath.row]
        cell.configure(with: city)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.navigateToDetailWeatherCity(viewModel.cityItems[indexPath.row].latitude, lon: viewModel.cityItems[indexPath.row].longitude)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.searchCity(query: query)
    }
}

extension SearchCityViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.clearItems()
    }
}

// MARK: - TextField Delegates
extension SearchCityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty && range.length > 0 {
            viewModel.clearItems()
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.clearItems()
        return true
    }
}
