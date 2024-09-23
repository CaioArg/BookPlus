import UIKit
import SceneKit
import ARKit

class SceneViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    var pages: [Page]!
    var configuration: ARImageTrackingConfiguration!
    var bookPlus: BookPlus!

    override func viewDidLoad() {
        super.viewDidLoad()
        configuration = ARImageTrackingConfiguration()
        sceneView.scene = SCNScene()
        bookPlus = BookPlus(pages, sceneView, configuration)
        sceneView.delegate = bookPlus
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
