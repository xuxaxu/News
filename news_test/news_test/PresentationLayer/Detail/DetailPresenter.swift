import Foundation

class DetailPresenter {
    weak var view: DetailViewInput? {
        didSet {
            if let article {
                view?.update(with: .success(article))
            } else {
                view?.update(with: .loading)
            }
        }
    }
    private var article: Article? {
        didSet {
            if let article {
                view?.update(with: .success(article))
            }
        }
    }
    
    public init(article: Article) {
        self.article = article
    }
}

extension DetailPresenter: DetailViewOutput {
    
}
