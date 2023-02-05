import Foundation
import UIKit

struct Article {
    let source: String?
    let title: String
    let description: String?
    let image: UIImage?
    let date: Date?
    let url: URL?
    let urlToImage: URL?
}

struct NewsListItem {
    let image: UIImage?
    let title: String
    let detailed: Int 
}
