import ARKit

class SceneViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    var pages: [Page]!
    private var bookPlus: BookPlus!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bookPlus = BookPlus(with: pages, for: sceneView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bookPlus.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bookPlus.pause()
    }
}
