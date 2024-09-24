//
//  SettingsViewController.swift
import UIKit
import ApphudSDK
import SafariServices

final class SettingsViewController: BaseViewController {
    
    // MARK: - Properties
    var delegateRouting: SettingsRouterDelegate?
    var viewModel = SettingsViewModel()

    // MARK: - Outlets
    
    private lazy var trialView: CustomTrialView = {
        let view = CustomTrialView(theme: .gradient)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.isHidden = Apphud.hasActiveSubscription()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UINib(nibName: "SettingsListCell", bundle: nil), forCellReuseIdentifier: "SettingsListCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.clipsToBounds = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    fileprivate var isOn = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        viewModel.viewController = self
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Settings"
    }
    
    private func showPremiumMessage() {
        let alertController = UIAlertController(
            title: "Premium Status",
            message: "You are already premium.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        alertController.addAction(okAction)

        present(
            alertController,
            animated: true,
            completion: nil
        )
    }

    private func setupHierarchy() {
        view.addSubviews([trialView, settingsTableView])
    }

    private func setupLayout() {
        if trialView.isHidden {
            NSLayoutConstraint.activate([
                settingsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                trialView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                trialView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                trialView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                trialView.heightAnchor.constraint(equalToConstant: 114),
                
                settingsTableView.topAnchor.constraint(equalTo: trialView.bottomAnchor),
                settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsItems.itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsListCell", for: indexPath) as! SettingsListCell
        let item = SettingsItems.itemsArray[indexPath.row]
        cell.configure(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [0, 0]: // Technical support
            viewModel.sendEmailToSupport()
        case [0, 2]: // Privacy Policy
            openURL(Url.privacy.rawValue)
        case [0, 3]: // Terms of Use
            openURL(Url.terms.rawValue)
        default:
            break
        }
    }
}

// MARK: - CustomTrialViewDelegate
extension SettingsViewController: CustomTrialViewDelegate {
    
    func premiumButtonTapped() {
        let paywallViewController = PaywallViewController()
        paywallViewController.modalPresentationStyle = .overFullScreen
        paywallViewController.modalTransitionStyle = .crossDissolve
        self.present(paywallViewController, animated: true)
    }
}
