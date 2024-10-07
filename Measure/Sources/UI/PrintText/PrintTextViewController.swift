//
//  PrintTextViewController.swift
//  Printer

import UIKit

final class PrintTextViewController: BaseViewController, UITextViewDelegate {
    
    @IBOutlet private weak var textTextView: UITextView!
    let placeholderLabel = UILabel()
    
    private lazy var printButton: UIButton = {
        let button = UIButton(type: .system)
        Theme.buttonStyle(button, title: "Print")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(printButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor(hexString: "#C3C7D7")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Print Text"
        textTextView.delegate = self
        textTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        placeholderLabel.text = "Type text here..."
        placeholderLabel.font = Fonts.regular.addFont(16)
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 16, y: textTextView.textContainerInset.top)
        placeholderLabel.textColor = UIColor(hexString: "56637B")
        placeholderLabel.isHidden = !textTextView.text.isEmpty
        textTextView.addSubview(placeholderLabel)
        setupPrintButton()
    }
    
    private func setupPrintButton() {
        view.addSubview(printButton)
        
        NSLayoutConstraint.activate([
            printButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            printButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            printButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            printButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" { // "\n" соответствует клавише "Return" или "Done"
            textView.resignFirstResponder() // Скрыть клавиатуру
            return false // Возвращаем false, чтобы предотвратить добавление новой строки
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        if textView.text.isEmpty {
            printButton.isEnabled = false
            printButton.backgroundColor = UIColor(hexString: "#C3C7D7")
        } else {
            Theme.buttonStyle(printButton, title: "Print")
        }
    }

    @objc private func printButtonTapped() {
        if textTextView.text.isEmpty {
            let alert = UIAlertController(title: nil, message: "You need to type something to print!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            let printController = UIPrintInteractionController.shared
            
             let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
             printController.printInfo = printInfo
            
            let formatter = UIMarkupTextPrintFormatter(markupText: textTextView.text)
             formatter.startPage = 0
             printController.printFormatter = formatter
                
             printController.present(animated: true, completionHandler: nil)
        }
    }
}
