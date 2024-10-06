//
//  PrintWebViewController.swift
//  Printer

import UIKit
import WebKit

final class PrintWebViewController: BaseViewController, UISearchBarDelegate, WKNavigationDelegate {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var webview: WKWebView!

    private lazy var printButton: UIButton = {
        let button = UIButton(type: .system)
        Theme.buttonStyle(button, title: "Print")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(printButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor(hexString: "#C3C7D7")
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPrintButton()
        
        searchBar.delegate = self
        webview.navigationDelegate = self
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
    
    private func setupPrintButton() {
        view.addSubview(printButton)

        NSLayoutConstraint.activate([
            printButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            printButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            printButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            printButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard var urlString = searchBar.text else { return }
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        guard let url = URL(string: urlString) else {
            let alert = UIAlertController(title: "Invalid URL", message: "Please enter a valid website URL.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let request = URLRequest(url: url)
        webview.load(request)
        searchBar.resignFirstResponder()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        printButton.isEnabled = true
        Theme.buttonStyle(printButton, title: "Print")
    }

    @objc private func printButtonTapped() {
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Web Page Print"
        printController.printInfo = printInfo
        
        printController.printFormatter = webview.viewPrintFormatter()
        
        printController.present(animated: true, completionHandler: nil)
    }
}
