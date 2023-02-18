import UIKit

public let imagesDictionaryReducer: (inout [URL: UIImage], ImageAction) -> [Effect<ImageAction>] = { images, action in
    switch action {
    case .setImage(image: let image, url: let url):
        images[url] = image
    }
    return []
}

public enum ImageAction {
    case setImage(image: UIImage, url: URL)
}
