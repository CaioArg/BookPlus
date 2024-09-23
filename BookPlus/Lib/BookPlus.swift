import SceneKit
import ARKit

class BookPlus: NSObject {
    var pages: [Page]!
    var sceneView: ARSCNView!
    var configuration: ARImageTrackingConfiguration!

    init (_ pages: [Page], _ sceneView: ARSCNView, _ configuration: ARImageTrackingConfiguration) {
        self.pages = pages
        self.sceneView = sceneView
        self.configuration = configuration

        configuration.trackingImages = Set(self.pages.map { $0.pageImage })
        configuration.maximumNumberOfTrackedImages = 1
    }

    private func getNodeForPage(_ page: Page, _ imageAnchor: ARImageAnchor) -> SCNNode {
        return switch page.contentType {
            case .text: getTextNode(page.textToBeDisplayed, imageAnchor)
            case .image: getImageNode(page.imageToBeDisplayed, imageAnchor)
            case .video: getVideoNode(page.videoToBeDisplayed, imageAnchor)
        }
    }

    private func getTextNode(_ textToBeDisplayed: String?, _ imageAnchor: ARImageAnchor) -> SCNNode {
        guard let textToBeDisplayed = textToBeDisplayed else { fatalError("no text to be displayed provided") }

        let textGeometry = SCNText(string: splitIntoLines(textToBeDisplayed, charsPerLine: 35), extrusionDepth: 0.1)
        textGeometry.font = UIFont.systemFont(ofSize: 0.6)
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

    private func getImageNode(_ imageToBeDisplayed: UIImage?, _ imageAnchor: ARImageAnchor) -> SCNNode {
        guard let imageToBeDisplayed = imageToBeDisplayed else { fatalError("no image to be displayed provided") }

        let planeSize = getPlaneSize(for: imageToBeDisplayed.size, withMaxSize: 0.08)

        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        plane.firstMaterial?.diffuse.contents = imageToBeDisplayed
        plane.firstMaterial?.isDoubleSided = true
        plane.cornerRadius = 0.003

        let imageNode = SCNNode(geometry: plane)
        imageNode.eulerAngles.x = -.pi / 2
        imageNode.position = SCNVector3(0, 0.005, 0)

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

        let planeSize = getPlaneSize(for: videoSize, withMaxSize: 0.08)

        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        plane.firstMaterial?.diffuse.contents = skScene
        plane.firstMaterial?.isDoubleSided = true
        plane.cornerRadius = 0.003

        let videoNode = SCNNode(geometry: plane)
        videoNode.eulerAngles.x = -.pi / 2
        videoNode.position = SCNVector3(0, 0.005, 0)

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

extension BookPlus: ARSCNViewDelegate {
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
