import UIKit

class ListPagesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var pages = [Page]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pages"
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func didTapAdd() {
        let addPageViewController = storyboard?.instantiateViewController(withIdentifier: "add-page") as! AddPageViewController

        addPageViewController.onSave = { page in
            DispatchQueue.main.async {
                self.pages.append(page)
                self.tableView.reloadData()
            }
        }

        navigationController?.pushViewController(addPageViewController, animated: true)
    }

    @IBAction func didTapBook() {
        let sceneViewController = storyboard?.instantiateViewController(withIdentifier: "scene") as! SceneViewController

        sceneViewController.pages = pages

        navigationController?.pushViewController(sceneViewController, animated: true)
    }
}

extension ListPagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ListPagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let page = pages[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(page.bookName) | \(page.pageNumber)"
        return cell
    }
}
