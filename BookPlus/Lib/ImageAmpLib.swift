import ARKit

public class ImageAmpLib: NSObject, ARSCNViewDelegate {
    private let imageEntries: [ImageEntry]
    private let sceneView: ARSCNView
    private let configuration = ARImageTrackingConfiguration()

    public init(with imageEntries: [ImageEntry], for sceneView: ARSCNView) {
        self.imageEntries = imageEntries
        self.sceneView = sceneView

        self.configuration.trackingImages = Set(self.imageEntries.map { $0.image })
        self.configuration.maximumNumberOfTrackedImages = 1

        super.init()

        self.sceneView.scene = SCNScene()
        self.sceneView.delegate = self
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let anchor = anchor as? ARImageAnchor else { return nil }
        guard let renderStrategy = imageEntries.first(where: { $0.image == anchor.referenceImage })?.renderStrategy else { return nil }
        return renderStrategy.getNode()
    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        guard !node.isHidden else { return }
        sceneView.session.remove(anchor: imageAnchor)
    }

    public func run() {
        self.sceneView.session.run(self.configuration)
    }

    public func pause() {
        self.sceneView.session.pause()
    }
}
