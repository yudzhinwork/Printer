//
//  OnboardingSucceessViewController.swift
//  Printer

import UIKit

class OnboardingSucceessViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first else {
                 return
             }
             
             let paywallViewController = PaywallViewController()
             window.rootViewController = UINavigationController(rootViewController: paywallViewController)
             UIView.transition(with: window,
                               duration: 0.5,
                               options: .transitionCrossDissolve,
                               animations: nil)
        }
    }
}
