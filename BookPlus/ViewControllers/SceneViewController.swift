import UIKit
import SceneKit
import ARKit

class SceneViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!

    var pages: [Page]?

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.scene = SCNScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "BookPages", bundle: Bundle.main) else { fatalError("No reference images found") }
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

extension SceneViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        if let imageAnchor = anchor as? ARImageAnchor {
            let cardWidth = imageAnchor.referenceImage.physicalSize.width
            let cardHeight = imageAnchor.referenceImage.physicalSize.height

            let text = SCNText(string: "Seu Texto Aqui esta digitado aqui em o texto bem grande", extrusionDepth: 1)
            text.font = UIFont.systemFont(ofSize: 20)
            text.flatness = 0.1
            text.firstMaterial?.diffuse.contents = UIColor.red
//            text.containerFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
//            text.isWrapped = true

            let textNode = SCNNode(geometry: text)
//            let textScale = cardWidth / CGFloat(text.boundingBox.max.x - text.boundingBox.min.x)
//            textNode.scale = SCNVector3(textScale, textScale, textScale)
//            textNode.position = SCNVector3(-cardWidth / 2, -cardHeight / 2, 0.00)

//            let card = SCNPlane(width: cardWidth, height: cardHeight)
//            card.cornerRadius = 0.003
//            card.firstMaterial?.diffuse.contents = UIColor.purple.withAlphaComponent(0.99)

//            let cardNode = SCNNode(geometry: card)
//            cardNode.eulerAngles.x = -.pi / 2
//            cardNode.addChildNode(textNode)
            textNode.eulerAngles.x = -.pi / 2

            node.addChildNode(textNode)
        }

        return node
    }
}
