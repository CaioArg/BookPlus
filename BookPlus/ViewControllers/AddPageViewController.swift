import ARKit
import UIKit

class AddPageViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var bookNameField: UITextField!
    @IBOutlet weak var pageNumberField: UITextField!
    @IBOutlet weak var pagePhysicalWidthField: UITextField!
    @IBOutlet weak var selectPageImageButton: UIButton!
    @IBOutlet weak var contentTypeField: UIPickerView!
    @IBOutlet weak var textToBeDisplayedField: UITextField!
    @IBOutlet weak var selectImageToBeDisplayedButton: UIButton!
    @IBOutlet weak var selectVideoToBeDisplayedButton: UIButton!
    
    var onSave: ((Page) -> Void)?
    
    private var pageImage: UIImage?
    private var imageToBeDisplayed: UIImage?
    private var videoToBeDisplayed: URL?

    private var pageImagePickerController = UIImagePickerController()
    private var imageToBeDisplayedPickerController = UIImagePickerController()
    private var videoToBeDisplayedPickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        self.title = "Add Page"
        
        bookNameField.delegate = self
        pageNumberField.delegate = self
        pagePhysicalWidthField.delegate = self
        contentTypeField.delegate = self
        contentTypeField.dataSource = self
        textToBeDisplayedField.delegate = self

        pageImagePickerController.delegate = self
        pageImagePickerController.sourceType = .photoLibrary
        pageImagePickerController.mediaTypes = [UTType.image.identifier]

        imageToBeDisplayedPickerController.delegate = self
        imageToBeDisplayedPickerController.sourceType = .photoLibrary
        imageToBeDisplayedPickerController.mediaTypes = [UTType.image.identifier]

        videoToBeDisplayedPickerController.delegate = self
        videoToBeDisplayedPickerController.sourceType = .photoLibrary
        videoToBeDisplayedPickerController.mediaTypes = [UTType.movie.identifier]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(savePage))
    }

    @IBAction func selectPageImage(_ sender: UIButton) {
        present(pageImagePickerController, animated: true, completion: nil)
    }

    @IBAction func selectImageToBeDisplayed(_ sender: UIButton) {
        present(imageToBeDisplayedPickerController, animated: true, completion: nil)
    }

    @IBAction func selectVideoToBeDisplayed(_ sender: UIButton) {
        present(videoToBeDisplayedPickerController, animated: true, completion: nil)
    }

    @objc func savePage() {
        guard let bookName = bookNameField.text, !bookName.isEmpty else {
            showValidationError()
            return
        }

        guard let pageNumberText = pageNumberField.text, !pageNumberText.isEmpty, let pageNumber = Int(pageNumberText) else {
            showValidationError()
            return
        }

        guard let pagePhysicalWidthText = pagePhysicalWidthField.text, !pagePhysicalWidthText.isEmpty, let pagePhysicalWidthInCentimeters = Float(pagePhysicalWidthText) else {
            showValidationError()
            return
        }

        let pagePhysicalWidth = CGFloat(pagePhysicalWidthInCentimeters / 100)

        let contentType = ContentType.allCases[contentTypeField.selectedRow(inComponent: 0)]
        
        if (pageImage?.cgImage == nil) {
            showValidationError()
            return
        }
        
        let pageImage = ARReferenceImage(pageImage!.cgImage!, orientation: .up, physicalWidth: pagePhysicalWidth)

        var page = Page(
            bookName: bookName,
            pageNumber: pageNumber,
            pageImage: pageImage,
            contentType: contentType
        )
        
        if contentType == .text {
            guard let textToBeDisplayed = textToBeDisplayedField.text, !textToBeDisplayed.isEmpty else {
                showValidationError()
                return
            }

            page.textToBeDisplayed = textToBeDisplayed
        }
        
        if contentType == .image {
            guard let imageToBeDisplayed = imageToBeDisplayed else {
                showValidationError()
                return
            }

            page.imageToBeDisplayed = imageToBeDisplayed
        }
        
        if contentType == .video {
            guard let videoToBeDisplayed = videoToBeDisplayed else {
                showValidationError()
                return
            }

            page.videoToBeDisplayed = videoToBeDisplayed
        }

        onSave?(page)
        navigationController?.popViewController(animated: true)
    }
    
    private func showValidationError() {
        let alert = UIAlertController(title: "Missing data", message: "Not all fields were filled", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AddPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddPageViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ContentType.allCases[row].rawValue
    }
}

extension AddPageViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ContentType.allCases.count
    }
}

extension AddPageViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker == pageImagePickerController {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }

            pageImage = selectedImage

            selectPageImageButton.setTitle("Page image selected", for: .normal)
            selectPageImageButton.tintColor = UIColor.systemGreen

            picker.dismiss(animated: true, completion: nil)
        }
        
        if picker == imageToBeDisplayedPickerController {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }

            imageToBeDisplayed = selectedImage

            selectImageToBeDisplayedButton.setTitle("Image to be displayed selected", for: .normal)
            selectImageToBeDisplayedButton.tintColor = UIColor.systemGreen

            picker.dismiss(animated: true, completion: nil)
        }

        if picker == videoToBeDisplayedPickerController {
            guard let selectedVideoUrl = info[.mediaURL] as? URL else { return }

            videoToBeDisplayed = selectedVideoUrl

            selectVideoToBeDisplayedButton.setTitle("Video to be displayed selected", for: .normal)
            selectVideoToBeDisplayedButton.tintColor = UIColor.systemGreen

            picker.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
