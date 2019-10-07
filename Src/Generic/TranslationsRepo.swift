//
//  TranslationsRepo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-13.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Foundation

struct TranslationsRepo {
    @Inject private var client: ApolloClient
    private static var translations: [String: String] = [:]

    func fetch() {
        let localeCode = String(describing: Localization.Locale.currentLocale)
        client.fetch(query: TranslationsQuery(code: localeCode)).onValue { result in
            let translations = result.data?.languages.first??.translations ?? []

            translations.forEach { translation in
                if let key = translation.key?.value {
                    TranslationsRepo.translations[key] = translation.text
                }
            }
        }
    }

    static func find(_ key: Localization.Key) -> String? {
        let stringifiedKey = String(describing: key)
        return TranslationsRepo.translations[stringifiedKey]
    }

    static func findWithReplacements(_ key: Localization.Key, replacements: [String: LocalizationStringConvertible]) -> String? {
        let stringifiedKey = key.description
        
        if var textValue = TranslationsRepo.translations[stringifiedKey] {
            replacements.forEach { key, value in
                textValue = textValue.replacingOccurrences(of: "{\(key)}", with: value.localizationDescription)
            }

            return textValue
        }

        return nil
    }
}
