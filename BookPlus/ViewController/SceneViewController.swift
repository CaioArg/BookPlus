import ARKit

class SceneViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!

    var pages: [Page]!

    private var configuration: ARImageTrackingConfiguration!
    private var bookPlus: BookPlus!

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = SCNScene()
        configuration = ARImageTrackingConfiguration()
        bookPlus = BookPlus(with: pages, for: sceneView, and: configuration)
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
