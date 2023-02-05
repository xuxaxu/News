class NewsListBuilder {
    private let presenter: NewsListPresenter
    public let viewController: NewsListViewController

    // MARK: - Init

    init() {
        presenter = NewsListPresenter(serviceCoordinator: ServiceCoordinatorImp.shared)
        viewController = NewsListViewController(output: presenter)
        presenter.view = viewController
    }
}
