import Foundation
import ARKit

struct Page {
    var bookName: String
    var pageNumber: Int
    var pageImage: ARReferenceImage
    var contentType: ContentType
    var textToBeDisplayed: String?
    var imageToBeDisplayed: UIImage?
    var videoToBeDisplayed: URL?
}
