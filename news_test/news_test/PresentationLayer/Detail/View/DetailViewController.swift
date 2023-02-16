import UIKit
import Foundation

class DetailViewController: UIViewController {
    public var output: DetailViewOutput
    private var article: Article? {
        didSet {
            imageView.image = article?.image
        }
    }
    
    public init(output: DetailViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView(image: .init(systemName: "photo"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubViews()
    }
    private func configureSubViews() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension DetailViewController: DetailViewInput {
    func update(with data: DetailViewState) {
        switch data {
        case .error:
            break
        case .loading:
            break
        case .success(let article):
            self.article = article
        }
    }
}
