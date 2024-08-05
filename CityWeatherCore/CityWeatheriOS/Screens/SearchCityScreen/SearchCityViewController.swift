import UIKit
import Combine
import CityWeatherCore

final class SearchCityViewController: UIViewController {
    
    private let viewModel: SearchCityViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    weak var coordinator: MainCoordinator?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let indicatorParentView = UIView()
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
        
        setupTableView()
        bindViewModel()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUI()
        setupIndicatorView()
        setupNoResultsLabel()
    }
    
    private func bindViewModel() {
        viewModel.$cityItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
                if self.viewModel.cityItems.isEmpty && self.searchController.searchBar.text!.count > 3 {
                    self.noResultsLabel.showWithOpacityEffect()
                } else {
                    self.noResultsLabel.hideWithOpacityEffect()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                isLoading ? self.indicatorView.startAnimating() : self.indicatorView.stopAnimating()
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard self != nil else { return }
                if let error = error {
                    // Handle error
                    print("Error: \(error.localizedDescription)")
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Helper methods
private extension SearchCityViewController {
    private func setUpUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Weather"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupIndicatorView() {
        indicatorParentView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorParentView.addSubview(indicatorView)
        
        view.addSubview(indicatorParentView)
        
        NSLayoutConstraint.activate([
            indicatorParentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            indicatorParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicatorParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            indicatorParentView.heightAnchor.constraint(equalToConstant: 30),
            
            indicatorView.centerXAnchor.constraint(equalTo: indicatorParentView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: indicatorParentView.centerYAnchor)
        ])
        
        view.bringSubviewToFront(indicatorParentView)
    }
    
    private func setupNoResultsLabel() {
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsLabel.text = "No Cities Match Your Search"
        noResultsLabel.isHidden = true
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .gray
        
        view.addSubview(noResultsLabel)
        
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.topAnchor.constraint(equalTo: indicatorParentView.bottomAnchor, constant: 20),
            noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search City"
        searchController.searchBar.searchTextField.autocorrectionType = .no
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.delegate = self
        definesPresentationContext = true
    }
}

// MARK: - TableView Setup and Delegate/DataSource Methods
extension SearchCityViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCityTableViewCell", for: indexPath) as! SearchCityTableViewCell
        cell.selectionStyle = .none
        cell.cityLabel.text = viewModel.displayName(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: -cell.frame.height)
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.85, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
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
