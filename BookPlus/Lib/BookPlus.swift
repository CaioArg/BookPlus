import ARKit

public class BookPlus: NSObject, ARSCNViewDelegate {
    private let pages: [Page]
    private let sceneView: ARSCNView
    private let configuration = ARImageTrackingConfiguration()

    public init(with pages: [Page], for sceneView: ARSCNView) {
        self.pages = pages
        self.sceneView = sceneView

        self.configuration.trackingImages = Set(self.pages.map { $0.pageImage })
        self.configuration.maximumNumberOfTrackedImages = 1
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let anchor = anchor as? ARImageAnchor else { return nil }
        guard let renderStrategy = pages.first(where: { $0.pageImage == anchor.referenceImage })?.renderStrategy else { return nil }
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
