import ARKit

class TextRenderStrategy: RenderStrategy {
    private let text: String

    init(for text: String) {
        self.text = text
    }

    func getNode() -> SCNNode {
        let textGeometry = SCNText(string: splitIntoLines(text, charsPerLine: 35), extrusionDepth: 0.1)
        textGeometry.font = UIFont.systemFont(ofSize: 2.5)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black

        let textNode = SCNNode(geometry: textGeometry)
        textNode.eulerAngles.x = -.pi / 2
        textNode.position = SCNVector3(0, 0.005, 0)
        textNode.scale = SCNVector3(0.0025, 0.0025, 0.0025)

        let textWidth = textGeometry.boundingBox.max.x - textGeometry.boundingBox.min.x
        let textHeight = textGeometry.boundingBox.max.y - textGeometry.boundingBox.min.y
        textNode.pivot = SCNMatrix4MakeTranslation(textWidth / 2, textHeight / 2, 0)

        let node = SCNNode()
        node.addChildNode(textNode)

        return node
    }
}
