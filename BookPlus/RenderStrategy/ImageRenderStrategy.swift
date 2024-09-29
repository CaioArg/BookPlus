import ARKit

class ImageRenderStrategy: RenderStrategy {
    private let image: UIImage

    init(for image: UIImage) {
        self.image = image
    }

    func getNode() -> SCNNode {
        let planeSize = getScaledSize(for: image.size, withMaxSize: 0.15)

        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided = true
        plane.cornerRadius = 0.003

        let imageNode = SCNNode(geometry: plane)
        imageNode.eulerAngles.x = -.pi / 2
        imageNode.position = SCNVector3(0, 0.005, 0)

        let node = SCNNode()
        node.addChildNode(imageNode)

        return node
    }
}
