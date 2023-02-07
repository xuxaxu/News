import UIKit

let imagesDictionaryReducer: (inout [URL: UIImage], ImageAction) -> Void = { images, action in
    switch action {
    case .setImage(image: let image, url: let url):
        images[url] = image
    }
}
