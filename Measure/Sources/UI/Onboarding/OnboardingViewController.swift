//
//  OnboardingViewController.swift

import UIKit
import StoreKit
import SwiftUI

final class OnboardingPageViewController: BaseViewController {
    
    // MARK: - UI Elements
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "NavigationButton-Skip")!, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipPressed), for: .touchUpInside)
        button.tintColor = UIColor(hexString: "#404A3E")
        return button
    }()
    
    private let titleTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(hexString: "#152239")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hexString: "#56637B")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    
    private var isFinalPage: Bool = false
    private var isFirstPage: Bool = false
    
    // MARK: - Initialization
    
    init(imageName: String, titleText: String, subtitleText: String, isFinalPage: Bool = false, isFirstPage: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = UIImage(named: imageName)
        self.titleTextLabel.text = titleText
        self.subTitleLabel.text = subtitleText
        self.isFinalPage = isFinalPage
        self.isFirstPage = isFirstPage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    var viewModel: OnboardingViewModel?
    var delegateRouting: OnboardingRouterDelegate?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        if isFinalPage {
            skipButton.isHidden = true
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(showCloseButton), userInfo: nil, repeats: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(titleTextLabel)
        view.addSubview(subTitleLabel)
        
        if isFirstPage {
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                imageView.bottomAnchor.constraint(equalTo: titleTextLabel.topAnchor, constant: 160),
                
                titleTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                titleTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//                titleTextLabel.heightAnchor.constraint(equalToConstant: 42),
                
                subTitleLabel.topAnchor.constraint(equalTo: titleTextLabel.bottomAnchor, constant: 16),
                subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                subTitleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -116),
//                subTitleLabel.heightAnchor.constraint(equalToConstant: 50),
            ])
        } else {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                imageView.bottomAnchor.constraint(equalTo: titleTextLabel.topAnchor, constant: 16),
                
                titleTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                titleTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//                titleTextLabel.heightAnchor.constraint(equalToConstant: 42),
                
                subTitleLabel.topAnchor.constraint(equalTo: titleTextLabel.bottomAnchor, constant: 16),
                subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                subTitleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -116),
//                subTitleLabel.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
    }
    
    @objc private func skipPressed() {
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
    
    @objc private func showCloseButton() {
        skipButton.isHidden = false
        skipButton.setImage(UIImage(named: "Close")!, for: .normal)
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
}

import UIKit

final class OnboardingViewController: UIViewController {
    
    var viewModel: OnboardingViewModel?
    var delegateRouting: OnboardingRouterDelegate?
    
    @AppStorage("isLaunchedBefore") var isLaunchedBefore = false

    // MARK: - UI Elements
    
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.dataSource = self
        pageVC.delegate = self
        
        for view in pageVC.view.subviews {
            if let subview = view as? UIScrollView {
                subview.isScrollEnabled = false
            }
        }
        
        return pageVC
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        Theme.buttonStyle(button, title: "Continue")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var pages: [UIViewController] = []
    private var currentIndex = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
        setupContinueButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if currentIndex >= 3 {
            continueButton.isHidden = true
         } else {
             Theme.buttonStyle(continueButton, title: "Continue")
         }
    }
    
    private func setupPages() {
        let page1 = OnboardingPageViewController(imageName: "Onboarding1",
                                                 titleText: "Supports Wi-Fi printer \nconnectivity",
                                                 subtitleText: "Wirelessly print photos and documents without any driver setup required.",
                                                 isFirstPage: true)
        let page2 = OnboardingPageViewController(imageName: "Onboarding2",
                                                 titleText: "Scan and print documents", subtitleText: "Convert files to PDF and print them directly from your phone")
        let page3 = OnboardingPageViewController(imageName: "Onboarding3",
                                                 titleText: "Easily import from any source",
                                                 subtitleText: "Import files from PC, email, iCloud, Dropbox, and Google Drive")
        let page4 = SelectPrinterViewController()
        
        let page5 = OnboardingSucceessViewController()
        
        pages = [page1, page2, page3, page4, page5]
    }

    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        guard let firstPage = pages.first else { return }
        pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

    // MARK: - Actions

    @objc private func continueButtonTapped() {
        guard currentIndex < pages.count - 1 else {
            print("Onboarding Completed")
            delegateRouting?.routeToMainView()
            return
        }
        // Вернуть
//        self.isLaunchedBefore = true
        currentIndex += 1
        let nextPage = pages[currentIndex]
        pageViewController.setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
        
        if nextPage is SelectPrinterViewController {
            
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
         }
     }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
}

