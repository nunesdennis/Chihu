//
//  String+Extension.swift
//  Chihu
//
//

import Foundation
import SwiftUI

extension String {
    var localized: String {
        // Add to localized file
        let _ = LocalizedStringKey(self)
        // Do the localization
        let localizedString =  String.LocalizationValue(stringLiteral: self)
        return String(localized: localizedString)
    }
}
