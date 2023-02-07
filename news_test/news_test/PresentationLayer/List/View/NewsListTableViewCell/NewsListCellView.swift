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
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        //label.font = UIFont.
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    private lazy var detailedLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func initialSetup() {
        self.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        addSubview(imageFirstView)
        addSubview(titleLabel)
        addSubview(detailedLabel)
        
        layoutMargins = UIEdgeInsets(top: DesignConstants.offset,
                                     left: DesignConstants.offset,
                                     bottom: -DesignConstants.offset,
                                     right: 0)
         
        preservesSuperviewLayoutMargins = false
    }
    
    func configure(with item: NewsListItem) {
        
        imageFirstView.image = item.image
        titleLabel.text = item.title
        detailedLabel.text = String(item.detailed)
       
        NSLayoutConstraint.activate([
            imageFirstView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: DesignConstants.leadingOffset),
            imageFirstView.topAnchor.constraint(equalTo: self.topAnchor),
            imageFirstView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageFirstView.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: DesignConstants.height),
            titleLabel.leadingAnchor.constraint(equalTo: imageFirstView.trailingAnchor, constant: DesignConstants.offset),
            titleLabel.trailingAnchor.constraint(equalTo: detailedLabel.leadingAnchor, constant: -DesignConstants.offset),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: DesignConstants.offset),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -DesignConstants.offset),
            detailedLabel.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: -DesignConstants.disclosureOffset),
            detailedLabel.topAnchor.constraint(equalTo: self.topAnchor),
            detailedLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            detailedLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -DesignConstants.offset*3)
        ])
        
    }
}

