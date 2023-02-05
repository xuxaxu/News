protocol NewsListViewInput: AnyObject {
    func update(with data: NewsListState)
    func navigateTo(destination: Int)
}
