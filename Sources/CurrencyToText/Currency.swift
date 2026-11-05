import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case portuguese
    case english
    case spanish
    case german
    case japanese
    case russian
    case french
    case korean
    case chineseSimplified

    var id: String { rawValue }

    var title: String {
        switch self {
        case .portuguese: "Português"
        case .english: "English"
        case .spanish: "Español"
        case .german: "Deutsch"
        case .japanese: "日本語"
        case .russian: "Русский"
        case .french: "Français"
        case .korean: "한국어"
        case .chineseSimplified: "简体中文"
        }
    }

    var amountPlaceholder: String {
        switch self {
        case .portuguese: "Ex.: 1.234,56"
        case .english: "e.g. 1,234.56"
        case .spanish: "Ej.: 1.234,56"
        case .german: "z. B. 1.234,56"
        case .japanese: "例: 1,234.56"
        case .russian: "Напр.: 1 234,56"
        case .french: "Ex. : 1 234,56"
        case .korean: "예: 1,234.56"
        case .chineseSimplified: "例：1,234.56"
        }
    }

    var decimalSeparator: Character {
        switch self {
        case .english, .japanese, .korean, .chineseSimplified: "."
        case .portuguese, .spanish, .german, .russian, .french: ","
        }
    }

    var groupingSeparator: Character {
        switch self {
        case .english, .japanese, .korean, .chineseSimplified: ","
        case .portuguese, .spanish, .german: "."
        case .russian, .french: " "
        }
    }

    func formattedAmountInput(_ input: String) -> String {
        guard !input.isEmpty else { return input }
        let sign = input.first == "-" || input.first == "+" ? String(input.prefix(1)) : ""
        let unsigned = sign.isEmpty ? input : String(input.dropFirst())
        let parts = unsigned.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2,
              parts.allSatisfy({ $0.allSatisfy { $0 >= "0" && $0 <= "9" } })
        else { return input }

        let whole = String(parts[0])
        let groupedCharacters = whole.reversed().enumerated().reduce(into: [Character]()) { result, item in
            if item.offset > 0 && item.offset.isMultiple(of: 3) {
                result.append(groupingSeparator)
            }
            result.append(item.element)
        }.reversed()
        var formatted = sign + String(groupedCharacters)
        if parts.count == 2 {
            formatted.append(decimalSeparator)
            formatted.append(contentsOf: parts[1])
        }
        return formatted
    }

    func normalizedAmountInput(_ input: String, allowAlternateDecimal: Bool = true) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        let sign = trimmed.first == "-" || trimmed.first == "+" ? String(trimmed.prefix(1)) : ""
        let unsigned = sign.isEmpty ? trimmed : String(trimmed.dropFirst())
        let decimalParts = unsigned.split(separator: decimalSeparator, omittingEmptySubsequences: false)
        if decimalParts.count == 2 {
            let whole = String(decimalParts[0])
            guard whole.split(separator: groupingSeparator, omittingEmptySubsequences: false)
                .allSatisfy({ $0.allSatisfy { $0 >= "0" && $0 <= "9" } })
            else { return trimmed }
            return sign + whole.replacingOccurrences(of: String(groupingSeparator), with: "")
                + "." + decimalParts[1]
        }
        guard decimalParts.count == 1 else { return trimmed }

        let groupingParts = unsigned.split(separator: groupingSeparator, omittingEmptySubsequences: false)
        if groupingParts.count > 1 {
            if isValidGroupedInteger(unsigned) {
                return sign + unsigned.replacingOccurrences(of: String(groupingSeparator), with: "")
            }
            if allowAlternateDecimal,
               groupingParts.count == 2,
               groupingParts[1].count <= 2,
               groupingParts.allSatisfy({ $0.allSatisfy { $0 >= "0" && $0 <= "9" } }) {
                return sign + groupingParts[0] + "." + groupingParts[1]
            }
            if groupingParts.allSatisfy({ $0.allSatisfy { $0 >= "0" && $0 <= "9" } }) {
                return sign + unsigned.replacingOccurrences(of: String(groupingSeparator), with: "")
            }
            return trimmed
        }
        return trimmed
    }

    private func isValidGroupedInteger(_ input: String) -> Bool {
        let groups = input.split(separator: groupingSeparator, omittingEmptySubsequences: false)
        guard groups.allSatisfy({ $0.allSatisfy { $0 >= "0" && $0 <= "9" } }) else { return false }
        guard groups.count > 1 else { return true }
        return (1...3).contains(groups[0].count)
            && groups.dropFirst().allSatisfy { $0.count == 3 }
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

    func majorGender(for language: AppLanguage) -> GrammaticalGender {
        switch language {
        case .portuguese, .spanish, .french:
            return self == .gbp ? .feminine : .masculine
        case .german:
            return .masculine
        case .russian:
            return self == .eur ? .neuter : .masculine
        case .english, .japanese, .korean, .chineseSimplified:
            return .masculine
        }
    }

    func majorName(_ language: AppLanguage, plural: Bool) -> String {
        if language == .russian {
            return russianMajorName(number: plural ? 2 : 1)
        }
        return switch (self, language, plural) {
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
        case (.eur, .german, false): "Euro"
        case (.eur, .german, true): "Euro"
        case (.usd, .german, false): "US-Dollar"
        case (.usd, .german, true): "US-Dollar"
        case (.gbp, .german, false): "Pfund Sterling"
        case (.gbp, .german, true): "Pfund Sterling"
        case (.brl, .german, false): "brasilianischer Real"
        case (.brl, .german, true): "brasilianische Reals"
        case (.eur, .japanese, _): "ユーロ"
        case (.usd, .japanese, _): "米ドル"
        case (.gbp, .japanese, _): "英ポンド"
        case (.brl, .japanese, _): "ブラジルレアル"
        case (.eur, .russian, _): "евро"
        case (.usd, .russian, _): "доллар"
        case (.gbp, .russian, _): "фунт стерлингов"
        case (.brl, .russian, _): "бразильский реал"
        case (.eur, .french, false): "euro"
        case (.eur, .french, true): "euros"
        case (.usd, .french, false): "dollar américain"
        case (.usd, .french, true): "dollars américains"
        case (.gbp, .french, false): "livre sterling"
        case (.gbp, .french, true): "livres sterling"
        case (.brl, .french, false): "réal brésilien"
        case (.brl, .french, true): "réaux brésiliens"
        case (.eur, .korean, _): "유로"
        case (.usd, .korean, _): "미국 달러"
        case (.gbp, .korean, _): "영국 파운드"
        case (.brl, .korean, _): "브라질 레알"
        case (.eur, .chineseSimplified, _): "欧元"
        case (.usd, .chineseSimplified, _): "美元"
        case (.gbp, .chineseSimplified, _): "英镑"
        case (.brl, .chineseSimplified, _): "巴西雷亚尔"
        }
    }

    func minorName(_ language: AppLanguage, plural: Bool) -> String {
        if language == .russian {
            return russianMinorName(number: plural ? 2 : 1)
        }
        return switch (self, language, plural) {
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
        case (.eur, .german, _): "Cent"
        case (.usd, .german, _), (.brl, .german, _): "Cent"
        case (.gbp, .german, false): "Penny"
        case (.gbp, .german, true): "Pence"
        case (.eur, .japanese, _): "セント"
        case (.usd, .japanese, _), (.brl, .japanese, _): "セント"
        case (.gbp, .japanese, _): "ペンス"
        case (.eur, .russian, _): "евроцент"
        case (.usd, .russian, _): "цент"
        case (.gbp, .russian, _): "пенс"
        case (.brl, .russian, _): "сентаво"
        case (.eur, .french, false): "centime"
        case (.eur, .french, true): "centimes"
        case (.usd, .french, false), (.brl, .french, false): "centime"
        case (.usd, .french, true), (.brl, .french, true): "centimes"
        case (.gbp, .french, false): "penny"
        case (.gbp, .french, true): "pence"
        case (.eur, .korean, _): "센트"
        case (.usd, .korean, _), (.brl, .korean, _): "센트"
        case (.gbp, .korean, _): "펜스"
        case (.eur, .chineseSimplified, _): "欧分"
        case (.usd, .chineseSimplified, _), (.brl, .chineseSimplified, _): "美分"
        case (.gbp, .chineseSimplified, _): "便士"
        }
    }

    func russianMajorName(number: Int) -> String {
        let form = russianForm(number)
        return switch self {
        case .eur: "евро"
        case .usd: form == 1 ? "доллар" : form == 2 ? "доллара" : "долларов"
        case .gbp: form == 1 ? "фунт стерлингов" : form == 2 ? "фунта стерлингов" : "фунтов стерлингов"
        case .brl: form == 1 ? "реал" : form == 2 ? "реала" : "реалов"
        }
    }

    func russianMinorName(number: Int) -> String {
        let form = russianForm(number)
        return switch self {
        case .eur: form == 1 ? "евроцент" : form == 2 ? "евроцента" : "евроцентов"
        case .usd: form == 1 ? "цент" : form == 2 ? "цента" : "центов"
        case .gbp: form == 1 ? "пенс" : form == 2 ? "пенса" : "пенсов"
        case .brl: form == 1 ? "сентаво" : form == 2 ? "сентаво" : "сентаво"
        }
    }

    private func russianForm(_ number: Int) -> Int {
        let lastTwo = number % 100
        if (11...14).contains(lastTwo) { return 3 }
        return switch number % 10 {
        case 1: 1
        case 2...4: 2
        default: 3
        }
    }
}

enum GrammaticalGender {
    case masculine
    case feminine
    case neuter
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
        let majorWords = NumberWords.spell(major, language: language, gender: currency.majorGender(for: language))
        let minorWords = NumberWords.spell(Int64(minor), language: language, gender: .masculine)

        let majorCurrencyName = language == .russian
            ? currency.russianMajorName(number: Int(major % 100))
            : currency.majorName(language, plural: major != 1)
        var result = "\(majorWords)\(language.wordSeparator)\(majorCurrencyName)"
        if minor > 0 {
            let minorCurrencyName = language == .russian
                ? currency.russianMinorName(number: minor)
                : currency.minorName(language, plural: minor != 1)
            result += "\(language.conjunction)\(minorWords)\(language.wordSeparator)\(minorCurrencyName)"
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
        case .german: " und "
        case .japanese, .chineseSimplified: ""
        case .russian: " и "
        case .french: " et "
        case .korean: " 그리고 "
        }
    }

    var wordSeparator: String {
        switch self {
        case .japanese, .chineseSimplified: ""
        default: " "
        }
    }

    var negativePrefix: String {
        switch self {
        case .portuguese: "menos "
        case .english: "minus "
        case .spanish: "menos "
        case .german: "minus "
        case .japanese: "マイナス"
        case .russian: "минус "
        case .french: "moins "
        case .korean: "마이너스 "
        case .chineseSimplified: "负"
        }
    }
}
