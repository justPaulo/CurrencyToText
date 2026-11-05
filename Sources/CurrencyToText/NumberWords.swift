import Foundation

enum NumberWords {
    private static let englishOnes = [
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
        "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
        "seventeen", "eighteen", "nineteen"
    ]
    private static let englishTens = [
        "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"
    ]
    private static let portugueseOnes = [
        "zero", "um", "dois", "três", "quatro", "cinco", "seis", "sete", "oito", "nove",
        "dez", "onze", "doze", "treze", "catorze", "quinze", "dezasseis", "dezassete",
        "dezoito", "dezanove"
    ]
    private static let portugueseTens = [
        "", "", "vinte", "trinta", "quarenta", "cinquenta", "sessenta", "setenta",
        "oitenta", "noventa"
    ]
    private static let portugueseHundreds = [
        "", "cento", "duzentos", "trezentos", "quatrocentos", "quinhentos",
        "seiscentos", "setecentos", "oitocentos", "novecentos"
    ]
    private static let spanishOnes = [
        "cero", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve",
        "diez", "once", "doce", "trece", "catorce", "quince", "dieciséis", "diecisiete",
        "dieciocho", "diecinueve", "veinte", "veintiuno", "veintidós", "veintitrés",
        "veinticuatro", "veinticinco", "veintiséis", "veintisiete", "veintiocho", "veintinueve"
    ]
    private static let spanishTens = [
        "", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta",
        "ochenta", "noventa"
    ]
    private static let spanishHundreds = [
        "", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos",
        "seiscientos", "setecientos", "ochocientos", "novecientos"
    ]

    static func spell(_ number: Int64, language: AppLanguage, gender: GrammaticalGender) -> String {
        guard number >= 0 else { return "" }
        if number == 0 { return zero(language) }

        var value = number
        var groups: [Int] = []
        while value > 0 {
            groups.append(Int(value % 1_000))
            value /= 1_000
        }

        var segments: [String] = []
        for index in groups.indices.reversed() where groups[index] > 0 {
            let group = groups[index]
            let segment: String
            if index == 0 {
                segment = chunk(group, language: language, gender: gender)
            } else {
                segment = scale(group, index: index, language: language, gender: gender)
            }
            segments.append(segment)
        }

        let separator = language == .english ? " " : " "
        var result = segments.joined(separator: separator)
        if language == .spanish {
            result = spanishGender(result, gender: gender)
        }
        return result
    }

    private static func zero(_ language: AppLanguage) -> String {
        switch language {
        case .portuguese: "zero"
        case .english: "zero"
        case .spanish: "cero"
        }
    }

    private static func scale(
        _ number: Int,
        index: Int,
        language: AppLanguage,
        gender: GrammaticalGender
    ) -> String {
        switch language {
        case .portuguese:
            if index == 1 { return number == 1 ? "mil" : "\(chunk(number, language: language, gender: gender)) mil" }
            if index == 3 {
                return "\(chunk(number, language: language, gender: gender)) mil milhões"
            }
            let noun = number == 1 ? "milhão" : "milhões"
            let prefix = number == 1 ? "um" : chunk(number, language: language, gender: gender)
            return "\(prefix) \(noun)"
        case .english:
            if index == 1 { return number == 1 ? "one thousand" : "\(chunk(number, language: language, gender: gender)) thousand" }
            let names = ["", "thousand", "million", "billion", "trillion"]
            return "\(chunk(number, language: language, gender: gender)) \(names[min(index, names.count - 1)])"
        case .spanish:
            if index == 1 { return number == 1 ? "mil" : "\(chunk(number, language: language, gender: gender)) mil" }
            if index == 3 {
                return number == 1 ? "mil millones" : "\(chunk(number, language: language, gender: gender)) mil millones"
            }
            let noun = number == 1 ? "millón" : "millones"
            let prefix = number == 1 ? "un" : chunk(number, language: language, gender: gender)
            return "\(prefix) \(noun)"
        }
    }

    private static func chunk(_ number: Int, language: AppLanguage, gender: GrammaticalGender) -> String {
        switch language {
        case .english:
            return englishChunk(number)
        case .portuguese:
            return portugueseChunk(number, gender: gender)
        case .spanish:
            return spanishChunk(number)
        }
    }

    private static func englishChunk(_ number: Int) -> String {
        if number < 20 { return englishOnes[number] }
        if number < 100 {
            let tens = englishTens[number / 10]
            let ones = number % 10
            return ones == 0 ? tens : "\(tens)-\(englishOnes[ones])"
        }
        let remainder = number % 100
        return remainder == 0
            ? "\(englishOnes[number / 100]) hundred"
            : "\(englishOnes[number / 100]) hundred \(englishChunk(remainder))"
    }

    private static func portugueseChunk(_ number: Int, gender: GrammaticalGender) -> String {
        if number < 20 {
            if number == 1 && gender == .feminine { return "uma" }
            return portugueseOnes[number]
        }
        if number < 100 {
            let tens = portugueseTens[number / 10]
            let remainder = number % 10
            if remainder == 0 { return tens }
            let ones = remainder == 1 && gender == .feminine ? "uma" : portugueseOnes[remainder]
            return "\(tens) e \(ones)"
        }
        if number == 100 { return "cem" }
        let hundreds = portugueseHundreds[number / 100]
        let remainder = number % 100
        return remainder == 0
            ? hundreds
            : "\(hundreds) e \(portugueseChunk(remainder, gender: gender))"
    }

    private static func spanishChunk(_ number: Int) -> String {
        if number < 30 { return spanishOnes[number] }
        if number < 100 {
            let tens = spanishTens[number / 10]
            let remainder = number % 10
            return remainder == 0 ? tens : "\(tens) y \(spanishOnes[remainder])"
        }
        if number == 100 { return "cien" }
        let hundreds = spanishHundreds[number / 100]
        let remainder = number % 100
        return remainder == 0 ? hundreds : "\(hundreds) \(spanishChunk(remainder))"
    }

    private static func spanishGender(_ input: String, gender: GrammaticalGender) -> String {
        guard gender == .masculine else {
            return input
                .replacingOccurrences(of: "veintiuno", with: "veintiuna")
                .replacingOccurrences(of: " y uno", with: " y una")
                .replacingOccurrences(of: "uno", with: "una")
        }
        return input
            .replacingOccurrences(of: "veintiuno", with: "veintiún")
            .replacingOccurrences(of: " y uno", with: " y un")
            .replacingOccurrences(of: "uno", with: "un")
    }
}
