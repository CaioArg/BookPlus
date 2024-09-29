import ARKit

class VideoRenderStrategy: RenderStrategy {
    private let video: URL

    init(for video: URL) {
        self.video = video
    }

    func getNode() -> SCNNode {
        let player = AVPlayer(url: video)

        let skVideoNode = SKVideoNode(avPlayer: player)
        skVideoNode.yScale = -1
        skVideoNode.play()

        let track = AVURLAsset(url: video).tracks(withMediaType: AVMediaType.video).first!
        let videoSize = track.naturalSize.applying(track.preferredTransform)

        let skScene = SKScene(size: videoSize)
        skScene.addChild(skVideoNode)

        skVideoNode.position = CGPoint(x: skScene.size.width / 2, y: skScene.size.height / 2)

        let planeSize = getScaledSize(for: videoSize, withMaxSize: 0.15)

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
}
