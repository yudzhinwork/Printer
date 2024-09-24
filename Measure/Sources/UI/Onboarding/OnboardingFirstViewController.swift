//
//  OnboardingFirstViewController.swift
//  PlantID

import UIKit
import SwiftUI

final class OnboardingFirstViewController: BaseViewController {
    
    // MARK: -
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Onboarding-1")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: - Properties
    
    var viewModel: OnboardingViewModel?
    var delegateRouting: OnboardingRouterDelegate?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.delegateRouting?.routeToPreparing()
        }
    }
}

private extension OnboardingFirstViewController {
    
    func configure() {
        setupHierarchy()
        setupConstraints()
    }
    
    func setupHierarchy() {
        view.addSubviews([backgroundImageView])
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
