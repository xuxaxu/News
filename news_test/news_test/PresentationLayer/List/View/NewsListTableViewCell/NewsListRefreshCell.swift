import Foundation
import UIKit

class NewsListRefreshCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        initialSetup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var refreshControl = UIImageView(image: .init(systemName: "add"))
    
    func initialSetup() {
        addSubview(refreshControl)
        
        layoutMargins = UIEdgeInsets(top: DesignConstants.offset,
                                     left: DesignConstants.offset,
                                     bottom: -DesignConstants.offset,
                                     right: 0)
         
        preservesSuperviewLayoutMargins = false
    }
    
    func configure() {
       
        NSLayoutConstraint.activate([
            refreshControl.topAnchor.constraint(equalTo: self.topAnchor),
            refreshControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            refreshControl.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}


