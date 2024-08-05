import UIKit

final class SearchCityTableViewCell: UITableViewCell {
    
    let cityLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        cityLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cityLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
