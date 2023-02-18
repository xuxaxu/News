import UIKit
import Foundation

class DetailViewController: UIViewController {
    public var output: DetailViewOutput
    private var article: Article? {
        didSet {
            imageView.image = article?.image
            adjustImageView(imageView)
            sourceView.text = article?.source
            titleLabel.text = article?.title
            textView.text = article?.description
            adjustTextView(textView)
            urlButton.setTitle(article?.url?.absoluteString, for: .normal)
        }
    }
    
    public init(output: DetailViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var scrollView = {
       let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    private lazy var sourceView: UILabel = {
       let label = UILabel()
        label.text = article?.source
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .systemGray
        return label
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.baselineAdjustment = .alignCenters
        label.text = article?.title
        return label
    }()
    private lazy var imageView: UIImageView = {
        let image = UIImageView(image: .init(systemName: "photo"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = DesignConstants.cornerRadius
        image.clipsToBounds = true
        return image
    }()
    private lazy var textView: UITextView = {
        let text = UITextView()
        text.font = .preferredFont(forTextStyle: .body)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = article?.description
        return text
    }()
    private lazy var urlButton: UIButton = {
        let button = UIButton()
        button.setTitle(article?.url?.absoluteString, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSubViews()
    }
    private func configureSubViews() {
        view.addSubview(scrollView)
        scrollView.contentSize.width = view.frame.width
        scrollView.addSubview(imageView)
        scrollView.addSubview(sourceView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(textView)
        scrollView.addSubview(urlButton)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignConstants.leadingOffset),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignConstants.leadingOffset),
            sourceView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: DesignConstants.leadingOffset),
            sourceView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: DesignConstants.leadingOffset),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: sourceView.bottomAnchor, constant: DesignConstants.offset),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignConstants.offset),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            urlButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: DesignConstants.offset),
            urlButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            urlButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            urlButton.heightAnchor.constraint(equalToConstant: DesignConstants.height)
        ])
    }
    private func adjustImageView(_ imageView: UIImageView) {
        guard let size = imageView.image?.size, size.width > 0, size.height > 0 else {
            return
        }
        let ratio = size.height / size.width
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width - 2*DesignConstants.leadingOffset).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor, multiplier: ratio).isActive = true
    }
    private func adjustTextView(_ textView: UITextView) {
        let width = view.frame.width - 2*DesignConstants.leadingOffset
        textView.widthAnchor.constraint(equalToConstant: width).isActive = true
        let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = newSize.height
        textView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
        textView.sizeToFit()
    }
    @objc private func buttonTap(_ sender: UIButton) {
        output.buttonAction()
    }
}

extension DetailViewController: DetailViewInput {
    func navigateToWebView() {
        CoordinatorImp.shared.openWebView(in: self)
    }
    
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
