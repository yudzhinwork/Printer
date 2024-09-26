//
//  SelectPrinterViewController.swift
//  Printer

import UIKit

class SelectPrinterViewController: BaseViewController {
    
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var otherButton: UIButton!
    
    private let printers = ["HP DeskJet", "HP Envy", "HP Office Jet", "HP LaserJet", "HP PhotoSmart",
    "HP 2000", "Epson EcoTank", "Canon imageCLASS", "Canon PIXMA", "Brother", "Xerox Phaser", "Epson WorkForce"]
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        Theme.buttonStyle(button, title: "Continue")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.backgroundColor = UIColor(hexString: "#C3C7D7")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @objc private func continueButtonTapped() {
        
    }
    
    func configure() {
        setupContinueButton()
        for (index, button)  in buttons.enumerated() {
            button.setTitle(printers[index], for: .normal)
            button.addTarget(self, action: #selector(printerAction), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(hexString: "#F6F4F9")?.cgColor
            button.setTitleColor(UIColor(hexString: "#152239"), for: .normal)
            button.titleLabel?.font = Fonts.regular.addFont(16)
        }
        otherButton.layer.cornerRadius = 8
        otherButton.layer.borderWidth = 1
        otherButton.layer.borderColor = UIColor(hexString: "#F6F4F9")?.cgColor
        otherButton.titleLabel?.font = Fonts.regular.addFont(16)
        otherButton.setTitleColor(UIColor(hexString: "#152239"), for: .normal)
        otherButton.setTitle("Other", for: .normal)
        otherButton.addTarget(self, action: #selector(printerAction), for: .touchUpInside)
    }
    
    private func resetButtons() {
        for button in buttons {
            button.layer.borderColor = UIColor(hexString: "#F6F4F9")?.cgColor
        }
        otherButton.layer.borderColor = UIColor(hexString: "#F6F4F9")?.cgColor
    }
    
    private func activateContinueButton() {
        continueButton.isEnabled = true
        Theme.buttonStyle(continueButton, title: "Continue")
    }
    
    private func setupContinueButton() {
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    @IBAction func otherAction(_ sender: UIButton) {
        
    }
    
    @objc func printerAction(_ sender: UIButton) {
        resetButtons()
        sender.layer.borderColor = UIColor(hexString: "#475DB6")?.cgColor
        activateContinueButton()
    }
}
