import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case portuguese
    case english
    case spanish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .portuguese: "Português"
        case .english: "English"
        case .spanish: "Español"
        }
    }

    var amountPlaceholder: String {
        switch self {
        case .portuguese: "Ex.: 123,45"
        case .english: "e.g. 123.45"
        case .spanish: "Ej.: 123,45"
        }
    }
}

enum Currency: String, CaseIterable, Identifiable {
    case eur
    case usd
    case gbp
    case brl

    var id: String { rawValue }

    var title: String {
        switch self {
        case .eur: "EUR — Euro"
        case .usd: "USD — US Dollar"
        case .gbp: "GBP — Pound Sterling"
        case .brl: "BRL — Brazilian Real"
        }
    }

    var majorGender: GrammaticalGender {
        self == .gbp ? .feminine : .masculine
    }

    func majorName(_ language: AppLanguage, plural: Bool) -> String {
        switch (self, language, plural) {
        case (.eur, .portuguese, false): "euro"
        case (.eur, .portuguese, true): "euros"
        case (.eur, .english, false): "euro"
        case (.eur, .english, true): "euros"
        case (.eur, .spanish, false): "euro"
        case (.eur, .spanish, true): "euros"
        case (.usd, .portuguese, false): "dólar americano"
        case (.usd, .portuguese, true): "dólares americanos"
        case (.usd, .english, false): "US dollar"
        case (.usd, .english, true): "US dollars"
        case (.usd, .spanish, false): "dólar estadounidense"
        case (.usd, .spanish, true): "dólares estadounidenses"
        case (.gbp, .portuguese, false): "libra esterlina"
        case (.gbp, .portuguese, true): "libras esterlinas"
        case (.gbp, .english, false): "pound sterling"
        case (.gbp, .english, true): "pounds sterling"
        case (.gbp, .spanish, false): "libra esterlina"
        case (.gbp, .spanish, true): "libras esterlinas"
        case (.brl, .portuguese, false): "real"
        case (.brl, .portuguese, true): "reais"
        case (.brl, .english, false): "Brazilian real"
        case (.brl, .english, true): "Brazilian reals"
        case (.brl, .spanish, false): "real brasileño"
        case (.brl, .spanish, true): "reales brasileños"
        }
    }

    func minorName(_ language: AppLanguage, plural: Bool) -> String {
        switch (self, language, plural) {
        case (.eur, .portuguese, false): "cêntimo"
        case (.eur, .portuguese, true): "cêntimos"
        case (.eur, .english, false): "cent"
        case (.eur, .english, true): "cents"
        case (.eur, .spanish, false): "céntimo"
        case (.eur, .spanish, true): "céntimos"
        case (.usd, .portuguese, false), (.brl, .portuguese, false): "centavo"
        case (.usd, .portuguese, true), (.brl, .portuguese, true): "centavos"
        case (.usd, .english, false), (.brl, .english, false): "cent"
        case (.usd, .english, true), (.brl, .english, true): "cents"
        case (.usd, .spanish, false), (.brl, .spanish, false): "centavo"
        case (.usd, .spanish, true), (.brl, .spanish, true): "centavos"
        case (.gbp, .portuguese, false): "penny"
        case (.gbp, .portuguese, true): "pence"
        case (.gbp, .english, false): "penny"
        case (.gbp, .english, true): "pence"
        case (.gbp, .spanish, false): "penique"
        case (.gbp, .spanish, true): "peniques"
        }
    }
}

enum GrammaticalGender {
    case masculine
    case feminine
}

struct MoneyAmount {
    let major: Int64
    let minor: Int
    let isNegative: Bool

    static func parse(_ input: String) -> MoneyAmount? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let isNegative = trimmed.first == "-"
        let unsigned = (trimmed.first == "-" || trimmed.first == "+")
            ? String(trimmed.dropFirst())
            : trimmed
        let parts = unsigned.split(
            omittingEmptySubsequences: false,
            whereSeparator: { $0 == "." || $0 == "," }
        )
        guard parts.count <= 2 else { return nil }
        let whole = parts[0].isEmpty && parts.count == 2 ? "0" : String(parts[0])
        guard !whole.isEmpty,
              whole.allSatisfy({ $0 >= "0" && $0 <= "9" }),
              whole.count <= 12
        else { return nil }

        let fraction: String
        if parts.count == 2 {
            guard parts[1].count <= 2, parts[1].allSatisfy({ $0 >= "0" && $0 <= "9" }) else { return nil }
            fraction = String(parts[1]).padding(toLength: 2, withPad: "0", startingAt: 0)
        } else {
            fraction = "00"
        }

        guard let major = Int64(whole), let minor = Int(fraction) else { return nil }
        return MoneyAmount(major: major, minor: minor, isNegative: isNegative)
    }

    func words(currency: Currency, language: AppLanguage) -> String {
        let majorWords = NumberWords.spell(major, language: language, gender: currency.majorGender)
        let minorWords = NumberWords.spell(Int64(minor), language: language, gender: .masculine)

        var result = "\(majorWords) \(currency.majorName(language, plural: major != 1))"
        if minor > 0 {
            result += "\(language.conjunction)\(minorWords) \(currency.minorName(language, plural: minor != 1))"
        }
        if isNegative && (major != 0 || minor != 0) {
            result = "\(language.negativePrefix)\(result)"
        }
        return result
    }
}

private extension AppLanguage {
    var conjunction: String {
        switch self {
        case .portuguese: " e "
        case .english: " and "
        case .spanish: " y "
        }
    }

    var negativePrefix: String {
        switch self {
        case .portuguese: "menos "
        case .english: "minus "
        case .spanish: "menos "
        }
    }
}
