class DetailBuilder {
    private let presenter: DetailPresenter
    public let viewController: DetailViewController

    // MARK: - Init

    init() {
        guard let article = BuisnessLogicImp.shared.currentArticle() else {
            fatalError()
        }
        presenter = DetailPresenter(article: article)
        viewController = DetailViewController(output: presenter)
        presenter.view = viewController
            
    }
}

