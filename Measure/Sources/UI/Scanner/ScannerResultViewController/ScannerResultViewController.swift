//
//  ScannerResultViewController.swift
//  Printer

import UIKit

class ScannerResultViewController: BaseViewController {
    
    @IBOutlet private weak var scannedDocumentImageView: UIImageView!
    @IBOutlet private weak var printButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var documentNameLabel: UILabel!
    
    fileprivate var docImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan Of Document"
        self.scannedDocumentImageView.image = docImage
        Theme.buttonStyle(printButton, title: "Print")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Theme.buttonStyle(printButton, title: "Print")
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            tabBarController?.selectedIndex = 0 // Index of the first tab
        }
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
    }
    
    @IBAction func printAction(_ sender: UIButton) {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printController.printingItem = scannedDocumentImageView.image
        printController.present(animated: true, completionHandler: { (controller, completed, error) in
            if completed {
                self.navigationController?.popViewController(animated: true)
            } else if let error = error {
                print("Failed to print document: \(error.localizedDescription)")
            }
        })
    }
    
    func fill(_ image: UIImage) {
        self.docImage = image
    }
}
