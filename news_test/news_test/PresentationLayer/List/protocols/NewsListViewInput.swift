protocol NewsListViewInput: AnyObject {
    func update(with data: NewsListViewState)
    func navigateToDetail()
}
