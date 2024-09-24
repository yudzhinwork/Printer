//
//  SettingsItems.swift

import Foundation

struct SettingsItems: Hashable {
    var image: String
    var title: String
}

extension SettingsItems {
    static let itemsArray = [
        SettingsItems(image: "Settings-Support", title: "Support"),
        SettingsItems(image: "Settings-Privacy", title: "Privacy Policy"),
        SettingsItems(image: "Settings-Terms", title: "Terms of Use")
    ]
}
