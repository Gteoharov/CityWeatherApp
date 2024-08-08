import UIKit
import CityWeatherCore

public final class SearchCityTableViewCell: UITableViewCell {
    public let cityLabel = UILabel()
    let countryLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.selectionStyle = .none
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)
        
        NSLayoutConstraint.activate([
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            countryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            countryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with cityItem: CitySearchItem) {
        cityLabel.text = cityItem.name
        countryLabel.text = cityItem.country.flagEmoji
    }
}


