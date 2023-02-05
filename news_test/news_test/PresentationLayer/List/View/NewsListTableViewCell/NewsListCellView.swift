import Foundation
import UIKit

class NewsListCellView: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        initialSetup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var imageFirstView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        //label.font = UIFont.
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var openedLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func initialSetup() {
        self.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        addSubview(imageFirstView)
        addSubview(titleLabel)
        
        layoutMargins = UIEdgeInsets(top: 0,
                                     left: DesignConstants.offset,
                                     bottom: 0, right: 0)
        preservesSuperviewLayoutMargins = false
    }
    
    func configure(with item: NewsListItem) {
        
        imageFirstView.image = item.image
        titleLabel.text = item.title
        openedLabel.text = String(item.detailed)
       
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: DesignConstants.offset),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -DesignConstants.offset),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: DesignConstants.offset),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: DesignConstants.offset)
        ])
        
    }
}

