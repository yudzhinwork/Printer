//
//  PrinterViewController.swift
//  Printer

import UIKit
import UniformTypeIdentifiers

class PrinterViewController: BaseViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func fromFilesAction(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.plainText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func fromPhotosAction(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Unavailable", message: "This device does not have a camera.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func printTextAction(_ sender: UIButton) {
        let vc = PrintTextViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func fromWebPageAction(_ sender: UIButton) {
        let vc = PrintWebViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func printIDAction(_ sender: UIButton) {
        let vc = PrintIDCardViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = url.lastPathComponent
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.printingItem = data
            
            printController.present(animated: true, completionHandler: nil)
        } catch {
            print("Ошибка при чтении файла: \(error)")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        printImage(image)
    }
    
    func printImage(_ image: UIImage) {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = image
        
        printController.present(animated: true, completionHandler: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
