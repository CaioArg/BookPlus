import ARKit

class SceneViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    var imageEntries: [ImageEntry]!
    private var imageAmpLib: ImageAmpLib!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageAmpLib = ImageAmpLib(with: imageEntries, for: sceneView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageAmpLib.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.imageAmpLib.pause()
    }
}
