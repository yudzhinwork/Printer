//
//  ScannerResultViewController.swift
//  Printer

import UIKit

class ScannerResultViewController: BaseViewController {
    
    @IBOutlet private weak var scannedDocumentImageView: UIImageView!
    @IBOutlet private weak var printButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var documentNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan Of Document"
        Theme.buttonStyle(printButton, title: "Print")
    }
    
    @IBAction func printAction(_ sender: UIButton) {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printController.printingItem = scannedDocumentImageView.image
        printController.present(animated: true, completionHandler: nil)
    }

}
