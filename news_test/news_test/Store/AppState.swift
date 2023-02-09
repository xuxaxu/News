import Foundation
import UIKit

struct AppState {
    var items = [Article]()
    var currentPage: Int = 1
    var detailed = [Int: Int]()
    var images = [URL: UIImage]()
    var dataFromPersistance = false
}
