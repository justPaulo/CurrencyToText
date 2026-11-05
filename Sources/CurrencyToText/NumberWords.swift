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
    private static let germanOnes = [
        "null", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun",
        "zehn", "elf", "zwölf", "dreizehn", "vierzehn", "fünfzehn", "sechzehn", "siebzehn",
        "achtzehn", "neunzehn"
    ]
    private static let germanTens = [
        "", "", "zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig", "siebzig", "achtzig", "neunzig"
    ]
    private static let frenchOnes = [
        "zéro", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf",
        "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize"
    ]
    private static let frenchTens = ["", "", "vingt", "trente", "quarante", "cinquante", "soixante"]
    private static let russianOnes = [
        "ноль", "один", "два", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять",
        "десять", "одиннадцать", "двенадцать", "тринадцать", "четырнадцать", "пятнадцать",
        "шестнадцать", "семнадцать", "восемнадцать", "девятнадцать"
    ]
    private static let russianFeminineOnes = [
        "ноль", "одна", "две", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять",
        "десять", "одиннадцать", "двенадцать", "тринадцать", "четырнадцать", "пятнадцать",
        "шестнадцать", "семнадцать", "восемнадцать", "девятнадцать"
    ]
    private static let russianNeuterOnes = [
        "ноль", "одно", "два", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять",
        "десять", "одиннадцать", "двенадцать", "тринадцать", "четырнадцать", "пятнадцать",
        "шестнадцать", "семнадцать", "восемнадцать", "девятнадцать"
    ]
    private static let russianTens = [
        "", "", "двадцать", "тридцать", "сорок", "пятьдесят", "шестьдесят", "семьдесят",
        "восемьдесят", "девяносто"
    ]
    private static let russianHundreds = [
        "", "сто", "двести", "триста", "четыреста", "пятьсот", "шестьсот",
        "семьсот", "восемьсот", "девятьсот"
    ]
    private static let cjkDigits = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]

    static func spell(_ number: Int64, language: AppLanguage, gender: GrammaticalGender) -> String {
        guard number >= 0 else { return "" }
        if number == 0 { return zero(language) }
        if language == .japanese || language == .chineseSimplified || language == .korean {
            return cjkNumber(number, language: language)
        }

        var value = number
        var groups: [Int] = []
        while value > 0 {
            groups.append(Int(value % 1_000))
            value /= 1_000
        }

        var segments: [(index: Int, word: String)] = []
        for index in groups.indices.reversed() where groups[index] > 0 {
            let group = groups[index]
            let segment: String
            if index == 0 {
                segment = chunk(group, language: language, gender: gender)
            } else {
                segment = scale(group, index: index, language: language, gender: gender)
            }
            segments.append((index, segment))
        }

        var result = ""
        var previousIndex: Int?
        for segment in segments {
            if !result.isEmpty {
                if language == .german, segment.index == 0, previousIndex == 1 {
                    result += segment.word == "ein" ? "eins" : segment.word
                } else {
                    result += " " + segment.word
                }
            } else {
                result = segment.word
            }
            previousIndex = segment.index
        }
        if language == .spanish {
            result = spanishGender(result, gender: gender)
        }
        if language == .french, gender == .feminine, number == 1 {
            result = "une"
        }
        return result
    }

    private static func zero(_ language: AppLanguage) -> String {
        switch language {
        case .portuguese: "zero"
        case .english: "zero"
        case .spanish: "cero"
        case .german: "null"
        case .japanese: "零"
        case .russian: "ноль"
        case .french: "zéro"
        case .korean: "영"
        case .chineseSimplified: "零"
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
        case .german:
            if index == 1 { return number == 1 ? "eintausend" : "\(chunk(number, language: language, gender: gender))tausend" }
            if index == 2 { return "\(number == 1 ? "eine" : chunk(number, language: language, gender: gender)) \(number == 1 ? "Million" : "Millionen")" }
            if index == 3 { return "\(number == 1 ? "eine" : chunk(number, language: language, gender: gender)) \(number == 1 ? "Milliarde" : "Milliarden")" }
            return "\(chunk(number, language: language, gender: gender)) Billionen"
        case .french:
            if index == 1 { return number == 1 ? "mille" : "\(frenchChunk(number, gender: gender)) mille" }
            let noun = index == 2 ? (number == 1 ? "million" : "millions") : (number == 1 ? "milliard" : "milliards")
            return "\(number == 1 ? "un" : frenchChunk(number, gender: gender)) \(noun)"
        case .russian:
            return russianScale(number, index: index)
        case .japanese, .korean, .chineseSimplified:
            return ""
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
        case .german:
            return germanChunk(number)
        case .french:
            return frenchChunk(number, gender: gender)
        case .russian:
            return russianChunk(number, gender: gender)
        case .japanese, .korean, .chineseSimplified:
            return ""
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

    private static func germanChunk(_ number: Int) -> String {
        if number < 20 { return number == 1 ? "ein" : germanOnes[number] }
        if number < 100 {
            let ones = number % 10
            return ones == 0 ? germanTens[number / 10] : "\(ones == 1 ? "ein" : germanOnes[ones])und\(germanTens[number / 10])"
        }
        let hundreds = number / 100
        let remainder = number % 100
        let prefix = hundreds == 1 ? "ein" : germanOnes[hundreds]
        return prefix + "hundert" + (remainder == 0 ? "" : germanChunk(remainder))
    }

    private static func frenchChunk(_ number: Int, gender: GrammaticalGender) -> String {
        if number < 17 { return number == 1 && gender == .feminine ? "une" : frenchOnes[number] }
        if number < 20 { return "dix-" + frenchOnes[number - 10] }
        if number < 70 {
            let tens = number / 10
            let remainder = number % 10
            if remainder == 0 { return frenchTens[tens] }
            if remainder == 1 { return "\(frenchTens[tens]) et \(gender == .feminine ? "une" : "un")" }
            return "\(frenchTens[tens])-\(frenchOnes[remainder])"
        }
        if number < 80 {
            let remainder = number - 60
            return remainder == 11 ? "soixante et onze" : "soixante-\(frenchChunk(remainder, gender: .masculine))"
        }
        if number < 100 {
            let remainder = number - 80
            if remainder == 0 { return "quatre-vingts" }
            if remainder == 1 { return gender == .feminine ? "quatre-vingt-une" : "quatre-vingt-un" }
            return "quatre-vingt-\(frenchChunk(remainder, gender: .masculine))"
        }
        if number == 100 { return "cent" }
        let hundreds = number / 100
        let remainder = number % 100
        let prefix = hundreds == 1 ? "cent" : "\(frenchOnes[hundreds]) cent"
        return remainder == 0 ? "\(prefix)\(hundreds > 1 ? "s" : "")" : "\(prefix) \(frenchChunk(remainder, gender: gender))"
    }

    private static func russianChunk(_ number: Int, gender: GrammaticalGender) -> String {
        let ones: [String]
        switch gender {
        case .feminine: ones = russianFeminineOnes
        case .neuter: ones = russianNeuterOnes
        case .masculine: ones = russianOnes
        }
        if number < 20 { return ones[number] }
        if number < 100 {
            let remainder = number % 10
            return remainder == 0 ? russianTens[number / 10] : "\(russianTens[number / 10]) \(ones[remainder])"
        }
        let remainder = number % 100
        return remainder == 0
            ? russianHundreds[number / 100]
            : "\(russianHundreds[number / 100]) \(russianChunk(remainder, gender: gender))"
    }

    private static func russianScale(_ number: Int, index: Int) -> String {
        if index == 1 {
            let quantity = russianChunk(number, gender: .feminine)
            let noun = russianNounForm(number, singular: "тысяча", few: "тысячи", many: "тысяч")
            return "\(quantity) \(noun)"
        }
        let quantity = russianChunk(number, gender: .masculine)
        if index == 2 {
            return "\(quantity) \(russianNounForm(number, singular: "миллион", few: "миллиона", many: "миллионов"))"
        }
        return "\(quantity) \(russianNounForm(number, singular: "миллиард", few: "миллиарда", many: "миллиардов"))"
    }

    private static func russianNounForm(_ number: Int, singular: String, few: String, many: String) -> String {
        let lastTwo = number % 100
        if (11...14).contains(lastTwo) { return many }
        return switch number % 10 {
        case 1: singular
        case 2...4: few
        default: many
        }
    }

    private static func cjkNumber(_ number: Int64, language: AppLanguage) -> String {
        var value = number
        var groups: [Int] = []
        while value > 0 {
            groups.append(Int(value % 10_000))
            value /= 10_000
        }

        let scaleNames: [String]
        switch language {
        case .japanese: scaleNames = ["", "万", "億", "兆"]
        case .korean: scaleNames = ["", "만", "억", "조"]
        case .chineseSimplified: scaleNames = ["", "万", "亿", "兆"]
        default: return ""
        }

        var result = ""
        var previousIndex: Int?
        for index in groups.indices.reversed() where groups[index] > 0 {
            let group = groups[index]
            if let previousIndex,
               (previousIndex - index > 1 || group < 1_000),
               !result.hasSuffix("零"), !result.hasSuffix("영") {
                result += language == .korean ? "영" : "零"
            }
            if language != .korean || group != 1 || index == 0 {
                result += cjkChunk(group, language: language)
            }
            result += scaleNames[index]
            previousIndex = index
        }
        return result
    }

    private static func cjkChunk(_ number: Int, language: AppLanguage) -> String {
        let digits: [String]
        let units: [String]
        switch language {
        case .japanese:
            digits = cjkDigits
            units = ["", "十", "百", "千"]
        case .chineseSimplified:
            digits = cjkDigits
            units = ["", "十", "百", "千"]
        case .korean:
            digits = ["영", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]
            units = ["", "십", "백", "천"]
        default:
            return ""
        }

        let divisors = [1, 10, 100, 1_000]
        var output = ""
        var zeroPending = false
        for position in (0..<4).reversed() {
            let divisor = divisors[position]
            let digit = (number / divisor) % 10
            guard digit > 0 else {
                if language != .korean && !output.isEmpty && number % divisor > 0 {
                    zeroPending = true
                }
                continue
            }
            if zeroPending {
                output += language == .korean ? "영" : "零"
                zeroPending = false
            }
            let omitLeadingOne = digit == 1
                && ((position == 1 && language != .korean) || (position == 3 && language == .japanese))
            let omitKoreanOne = digit == 1 && position > 0 && language == .korean
            if !omitLeadingOne && !omitKoreanOne {
                output += digits[digit]
            }
            output += units[position]
        }
        return output
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
