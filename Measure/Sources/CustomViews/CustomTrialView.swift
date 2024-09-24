import UIKit

protocol CustomTrialViewDelegate: AnyObject {
    func premiumButtonTapped()
}

class CustomTrialView: UIView {

    weak var delegate: CustomTrialViewDelegate?

    // MARK: - Properties

    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PRO")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var printerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Settings-Printer")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var proIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Settings-Pro")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = 12
        stack.backgroundColor = .clear
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(upgradeContainerView)
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Unlock All Features"
        label.font = Fonts.bold.addFont(18)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var upgradeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Settings-Button")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Upgrade to premium"
        label.textColor = .white
        label.font = Fonts.bold.addFont(12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()

    private(set) lazy var customButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(premiumButtonTapped), for: .touchUpInside)
        return button
    }()

    init(theme: ThemeEnumForTrialView) {
        super.init(frame: .zero)
        setupUI(theme: theme)
        setupHierarchy()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(theme: ThemeEnumForTrialView) {
        titleLabel.textColor = Theme.mainBlue
    }
    
    private func setupHierarchy() {
        addSubview(backgroundImageView)
        addSubview(verticalStack)
        addSubview(proIconImageView)
        addSubview(customButton)
        addSubview(printerImageView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            proIconImageView.topAnchor.constraint(equalTo: verticalStack.topAnchor, constant: 22),
            proIconImageView.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor, constant: 12),
            
            verticalStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            customButton.topAnchor.constraint(equalTo: topAnchor),
            customButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            customButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            customButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            upgradeContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            printerImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            printerImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Actions

    @objc func premiumButtonTapped() {
        delegate?.premiumButtonTapped()
    }
}
