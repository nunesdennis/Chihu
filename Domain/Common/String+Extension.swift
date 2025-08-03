//
//  String+Extension.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 12/01/25.
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
