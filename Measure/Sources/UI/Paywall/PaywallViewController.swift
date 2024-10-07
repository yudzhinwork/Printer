import UIKit
import ApphudSDK
import AlertKit
import Combine

final class PaywallViewController: BaseViewController {

    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = "Printer App - Printer & Scanner"
        return label
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Close")!, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipPressed), for: .touchUpInside)
        button.tintColor = UIColor(hexString: "#475DB6")
        return button
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        Theme.buttonStyle(button, title: "Try 3 day free trial")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        return button
    }()
    
    private var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var bottomButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let restoreButton = createBottomButton(withTitle: "Restore Purchases", action: #selector(restoreTapped))
        let privacyButton = createBottomButton(withTitle: "Terms of Use", action: #selector(privacyTapped))
        let termsButton = createBottomButton(withTitle: "Privacy Policy", action: #selector(termsTapped))

        stackView.addArrangedSubview(restoreButton)
        stackView.addArrangedSubview(privacyButton)
        stackView.addArrangedSubview(termsButton)

        return stackView
    }()
    
    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Paywall-Image")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private(set) lazy var annuallyButton: CustomButton = {
        let button = CustomButton()
        button.configure(topText: "3 Days FREE", price: PremiumManager.shared.annuallyPrice, periodText: "billed annually", period: "year", isChosen: true)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(annuallyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var weeklyButton: CustomButton = {
        let button = CustomButton()
        button.configure(topText: "3 Days FREE", price: PremiumManager.shared.weeklyPrice, periodText: "week", period: "Weekly", isChosen: false)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(weeklyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var featureListStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 14
        stackView.alignment = .leading  // Выравнивание по левой стороне
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let items = [
            ("Paywall-List", "Scan Documents & Photos"),
            ("Paywall-List", "Print your photos"),
            ("Paywall-List", "Print your Saved Files"),
            ("Paywall-List", "Multiple Printer Support")
        ]
        
        for item in items {
            let imageView = UIImageView(image: UIImage(named: item.0))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true  // Фиксированная ширина для иконки
            imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            let label = UILabel()
            label.text = item.1
            label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor(hexString: "#152239")?.withAlphaComponent(0.65)
            
            // Создаем горизонтальный стек для иконки и текста
            let itemStack = UIStackView(arrangedSubviews: [imageView, label])
            itemStack.axis = .horizontal
            itemStack.spacing = 8
            itemStack.alignment = .center
            itemStack.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(itemStack)
        }
        return stackView
    }()
    
    var viewModel: OnboardingViewModel?
    var delegateRouting: OnboardingRouterDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        skipButton.isHidden = true
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(showCloseButton), userInfo: nil, repeats: false)
        
        PremiumManager.shared.$weeklyPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPrice in
                self?.updatePriceButtons()
            }
            .store(in: &cancellables)

        PremiumManager.shared.$annuallyPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPrice in
                self?.updatePriceButtons()
            }
            .store(in: &cancellables)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Theme.buttonStyle(continueButton, title: "try 3 day free trial".uppercased())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func updatePriceButtons() {
        weeklyButton.configure(topText: "3 Days FREE", price: PremiumManager.shared.weeklyPrice, periodText: "week", period: "week", isChosen: false)
        annuallyButton.configure(topText: "3 Days FREE", price: PremiumManager.shared.annuallyPrice, periodText: "year", period: "year", isChosen: true)
    }
    
    @objc func skipPressed() {
        closeAction()
    }
    
    func closeAction() {
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            MainCoordinator(navigationController: self.navigationController!).start()
        }
    }
    
    @objc private func showCloseButton() {
        skipButton.isHidden = false
        skipButton.setImage(UIImage(named: "Close")!, for: .normal)
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(skipButton)
        view.addSubview(weeklyButton)
        view.addSubview(annuallyButton)
        view.addSubview(continueButton)
        view.addSubview(backgroundImageView)
        view.addSubview(featureListStackView)
        view.addSubview(bottomButtonsStackView)
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            skipButton.heightAnchor.constraint(equalToConstant: 38),
            skipButton.widthAnchor.constraint(equalToConstant: 36),
            
            titleLabel.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 36),
            
            backgroundImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            featureListStackView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 30),
            featureListStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            featureListStackView.heightAnchor.constraint(equalToConstant: 128),
            featureListStackView.bottomAnchor.constraint(equalTo: annuallyButton.topAnchor, constant: -16),
            
            annuallyButton.bottomAnchor.constraint(equalTo: weeklyButton.topAnchor, constant: -16),
            annuallyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            annuallyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            annuallyButton.heightAnchor.constraint(equalToConstant: 64),
            
            weeklyButton.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),
            weeklyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            weeklyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            weeklyButton.heightAnchor.constraint(equalToConstant: 64),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: bottomButtonsStackView.topAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
            
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            bottomButtonsStackView.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    private func createBottomButton(withTitle title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        button.setTitleColor(UIColor(hexString: "#8F9A8C"), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    // MARK: - Button Actions

    @objc private func weeklyButtonTapped() {
        selectButton(weeklyButton)
    }

    @objc private func annuallyButtonTapped() {
        selectButton(annuallyButton)
    }
    
    @objc private func restoreTapped() {
        Apphud.restorePurchases { subscriptions, purchase, error in
            if Apphud.hasActiveSubscription() {
                AlertKitAPI.present(
                    title: "Restore successful",
                    style: .iOS17AppleMusic,
                    haptic: .success
                )
            }
        }
    }
    
    @objc private func privacyTapped() {
        openURL(Url.privacy.rawValue)
    }
    
    @objc private func termsTapped() {
        openURL(Url.terms.rawValue)
    }

    private func selectButton(_ selectedButton: CustomButton) {
        weeklyButton.isChoosen = false
        annuallyButton.isChoosen = false
        
        selectedButton.isChoosen = true
    }
    
    @objc private func buyTapped() {
        if weeklyButton.isChoosen {
            if let product = PremiumManager.weeklyProduct {
                Apphud.purchase(product) { [self] result in
                    if result.success {
                        closeAction()
                    }
                }
            }
        } else if annuallyButton.isChoosen {
            if let product = PremiumManager.annuallyProduct {
                Apphud.purchase(product) { [self] result in
                    if result.success {
                        closeAction()
                    }
                }
            }
        }
    }
}
