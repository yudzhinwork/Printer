//
//  PrintIDCardCropViewController.swift
//  Printer

import UIKit

final class PrintIDCardCropViewController: BaseViewController {
    
    @IBOutlet private weak var idCardIMageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fill(_ image: UIImage) {
        self.idCardIMageView.image = image
    }
}
