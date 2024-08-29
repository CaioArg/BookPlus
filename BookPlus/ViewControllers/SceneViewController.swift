import UIKit
import SceneKit
import ARKit

class SceneViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!

    var pages: [Page]!

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.scene = SCNScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = Set(pages.map { $0.pageImage })
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func getNodeForPage(_ page: Page, _ imageAnchor: ARImageAnchor) -> SCNNode {
        return switch page.contentType {
            case .text: getTextNode(page.textToBeDisplayed, imageAnchor)
            case .image: getImageNode(page.imageToBeDisplayed, imageAnchor)
            case .video: getVideoNode(page.videoToBeDisplayed, imageAnchor)
        }
    }
    
    // TODO - texto deve aparecer
    private func getTextNode(_ textToBeDisplayed: String?, _ imageAnchor: ARImageAnchor) -> SCNNode {
        guard let textToBeDisplayed = textToBeDisplayed else { fatalError("no text to be displayed provided") }

        let planeSize = CGSize(width: 0.10, height: 0.05)
        
        let text = SCNText(string: "Seu Texto Aqui esta digitado aqui em o texto bem grande", extrusionDepth: 1)
        text.font = UIFont.systemFont(ofSize: 20)
        text.flatness = 0.1
        text.firstMaterial?.diffuse.contents = UIColor.black
        text.containerFrame = CGRect(x: 0, y: 0, width: planeSize.width, height: planeSize.height)
        text.isWrapped = true

        let textNode = SCNNode(geometry: text)
        let textScale = planeSize.width / CGFloat(text.boundingBox.max.x - text.boundingBox.min.x)
        textNode.scale = SCNVector3(textScale, textScale, textScale)
        textNode.position = SCNVector3(-planeSize.width / 2, -planeSize.height / 2, 0.00)

        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        plane.cornerRadius = 0.0075
        plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.99)

        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.position = SCNVector3(0, 0.03, 0)
        planeNode.addChildNode(textNode)

        let node = SCNNode()
        node.addChildNode(planeNode)

        return node
    }

    private func getImageNode(_ imageToBeDisplayed: UIImage?, _ imageAnchor: ARImageAnchor) -> SCNNode {
        guard let imageToBeDisplayed = imageToBeDisplayed else { fatalError("no image to be displayed provided") }
        
        let planeSize = getPlaneSize(for: imageToBeDisplayed.size, withMaxSize: 0.15)
        
        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        plane.firstMaterial?.diffuse.contents = imageToBeDisplayed
        plane.firstMaterial?.isDoubleSided = true
        
        let imageNode = SCNNode(geometry: plane)
        imageNode.eulerAngles.x = -.pi / 2
        imageNode.position = SCNVector3(0, 0.03, 0)
        
        let node = SCNNode()
        node.addChildNode(imageNode)

        return node
    }

    private func getVideoNode(_ videoToBeDisplayed: URL?, _ imageAnchor: ARImageAnchor) -> SCNNode {
        guard let videoToBeDisplayed = videoToBeDisplayed else { fatalError("no video to be displayed provided") }

        let player = AVPlayer(url: videoToBeDisplayed)

        let skVideoNode = SKVideoNode(avPlayer: player)
        skVideoNode.yScale = -1
        skVideoNode.play()

        let track = AVURLAsset(url: videoToBeDisplayed).tracks(withMediaType: AVMediaType.video).first!
        let videoSize = track.naturalSize.applying(track.preferredTransform)

        let skScene = SKScene(size: videoSize)
        skScene.addChild(skVideoNode)
        
        skVideoNode.position = CGPoint(x: skScene.size.width / 2, y: skScene.size.height / 2)
        
        let planeSize = getPlaneSize(for: videoSize, withMaxSize: 0.15)
        
        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        plane.firstMaterial?.diffuse.contents = skScene
        plane.firstMaterial?.isDoubleSided = true
        
        let videoNode = SCNNode(geometry: plane)
        videoNode.eulerAngles.x = -.pi / 2
        videoNode.position = SCNVector3(0, 0.03, 0)
        
        let node = SCNNode()
        node.addChildNode(videoNode)

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        return node
    }
    
    private func getPlaneSize(for size: CGSize, withMaxSize maxSize: CGFloat) -> CGSize {
        let aspectRatio = size.width / size.height
        
        return aspectRatio > 1
            ? CGSize(width: maxSize, height: maxSize / aspectRatio)
            : CGSize(width: maxSize * aspectRatio, height: maxSize)
    }
}

extension SceneViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        guard let page = pages.first(where: { $0.pageImage == imageAnchor.referenceImage }) else { return nil }
        return getNodeForPage(page, imageAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        guard !node.isHidden else { return }

        sceneView.session.remove(anchor: imageAnchor)
    }
}
