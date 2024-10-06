//
//  MainCoordinator.swift

import UIKit

fileprivate enum TabItem: Int {
    case myGarden
    case scanner
    case history
    case profile
}

class MainCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {

        let tabBar = getTabBarContoller()
        navigationController.isNavigationBarHidden = true
        navigationController.setViewControllers([tabBar], animated: false)
    }
    
    private func getTabBarContoller() -> UITabBarController {
        let printerViewController = PrinterViewController()
        let printerNavigationController = UINavigationController(rootViewController: printerViewController)
        
        let scannerViewController = ScannerViewController()
        let scannerNavigationConntroller = UINavigationController(rootViewController: scannerViewController)
        
        let historyViewController = DocumentsViewController()
        let historyNavigationConntroller = UINavigationController(rootViewController: historyViewController)
        
        printerNavigationController.tabBarItem = UITabBarItem(title: "Printer",
                                                  image: UIImage(named: "TabBar-Printer"),
                                                  selectedImage: UIImage(named: "TabBar-Printer"))
        printerNavigationController.tabBarItem.tag = TabItem.myGarden.rawValue
        
        scannerNavigationConntroller.tabBarItem = UITabBarItem(title: "Scanner",
                                                  image: UIImage(named: "TabBar-Scanner"),
                                                  selectedImage: UIImage(named: "TabBar-Scanner"))
        scannerNavigationConntroller.tabBarItem.tag = TabItem.scanner.rawValue
        
        historyNavigationConntroller.tabBarItem = UITabBarItem(title: "Documents",
                                                            image: UIImage(named: "TabBar-Documents"),
                                                            selectedImage: UIImage(named: "TabBar-Documents"))
        historyNavigationConntroller.tabBarItem.tag = TabItem.history.rawValue
        
        let profileViewController = SettingsViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "Settings",
                                                            image: UIImage(named: "TabBar-Settings"),
                                                            selectedImage: UIImage(named: "TabBar-Settings"))
        let profileNavigationConntroller = UINavigationController(rootViewController: profileViewController)
        profileNavigationConntroller.tabBarItem.tag = TabItem.profile.rawValue
        
        let tabBarController = CustomTabBarController()
        
        tabBarController.viewControllers = [printerNavigationController,
                                            scannerNavigationConntroller,
                                            historyNavigationConntroller,
                                            profileNavigationConntroller]
        
        tabBarController.tabBar.unselectedItemTintColor = UIColor.dynamicColor(
            light: UIColor(hexString: "#9DA2B6")!,
            dark: UIColor(hexString: "#9DA2B6")!
        )
        
        tabBarController.tabBar.tintColor = UIColor.dynamicColor(
            light: UIColor(hexString: "#475DB6")!,
            dark: UIColor(hexString: "#475DB6")!
        )
        
        tabBarController.mainCoordinator = self
        
        return tabBarController
    }
    
    func showRulerScreen() {
        let rulerViewController = UIViewController()
        navigationController.pushViewController(rulerViewController, animated: true)
    }
    
    func showBubbleLevelScreen() {
        let bubbleLevelViewController = UIViewController()
        navigationController.pushViewController(bubbleLevelViewController, animated: true)
    }
}

// MARK: - OnboardingRoutingDelegate

extension MainCoordinator: MainRouterDelegate {
    func routeToSettings() {
        SettingsCoordinator(navigationController: navigationController).start()
    }

    func routeToCamera() {
        CameraCoordinator(navigationController: navigationController).start()
    }
    
    func routeToTrial() {
        PaywallCoordinator(navigationController: navigationController).start()
    }
}

final class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    var mainCoordinator: MainCoordinator?
    private var previousIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // Устанавливаем непрозрачный фон
        appearance.backgroundColor = .white // Устанавливаем белый фон
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let mainCoordinator = mainCoordinator,
        let tabItem = TabItem(rawValue: item.tag) else { return }
        switch tabItem {
        case .scanner:
            selectedIndex = tabItem.rawValue
        default:
            previousIndex = selectedIndex
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let _ = viewControllers?.firstIndex(of: viewController) {
            previousIndex = selectedIndex
        }
        if let navController = viewController as? UINavigationController {
              if navController.viewControllers.count > 1 {
                  navController.popToRootViewController(animated: false)
              }
        }
        return true
     }
}
