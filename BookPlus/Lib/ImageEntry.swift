import ARKit

public class ImageEntry {
    public let image: ARReferenceImage
    public let renderStrategy: RenderStrategy

    public init(image: ARReferenceImage, renderStrategy: RenderStrategy) {
        self.image = image
        self.renderStrategy = renderStrategy
    }
}
