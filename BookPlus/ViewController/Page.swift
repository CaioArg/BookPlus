import ARKit

public class Page : ImageEntry {
    public let bookName: String
    public let pageNumber: Int
    
    public init(bookName: String, pageNumber: Int, image: ARReferenceImage, renderStrategy: RenderStrategy) {
        self.bookName = bookName
        self.pageNumber = pageNumber

        super.init(image: image, renderStrategy: renderStrategy)
    }
}
