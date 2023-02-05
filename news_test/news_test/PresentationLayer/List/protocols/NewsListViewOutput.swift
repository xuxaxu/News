import Foundation

protocol NewsListViewOutput: AnyObject {
    func countOfItems() -> Int
    func getItem(for index: IndexPath) -> NewsListItem?
    func askForUpdate()
    func scroll()
    func itemSelected(indexPath: IndexPath)
    func getTitle() -> String
}
