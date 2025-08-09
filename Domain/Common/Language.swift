//
//  Language.swift
//  Chihu
//
//  Created by Dennis Nunes on 09/09/24.
//

import Foundation

enum Language {
    case af(region: Region?)
    case ar(region: Region?)
    case az(region: Region?)
    case be(region: Region?)
    case bg(region: Region?)
    case bs(region: Region?)
    case ca(region: Region?)
    case cs(region: Region?)
    case cy(region: Region?)
    case da(region: Region?)
    case de(region: Region?)
    case dv(region: Region?)
    case el(region: Region?)
    case en(region: Region?)
    case eo
    case es(region: Region?)
    case et(region: Region?)
    case eu(region: Region?)
    case fa(region: Region?)
    case fi(region: Region?)
    case fo(region: Region?)
    case fr(region: Region?)
    case gl(region: Region?)
    case gu(region: Region?)
    case he(region: Region?)
    case hi(region: Region?)
    case hr(region: Region?)
    case hu(region: Region?)
    case hy(region: Region?)
    case id(region: Region?)
    case `is`(region: Region?)
    case it(region: Region?)
    case ja(region: Region?)
    case ka(region: Region?)
    case kk(region: Region?)
    case kn(region: Region?)
    case ko(region: Region?)
    case kok(region: Region?)
    case ky(region: Region?)
    case lt(region: Region?)
    case lv(region: Region?)
    case mi(region: Region?)
    case mk(region: Region?)
    case mn(region: Region?)
    case mr(region: Region?)
    case ms(region: Region?)
    case mt(region: Region?)
    case nb(region: Region?)
    case nl(region: Region?)
    case nn(region: Region?)
    case ns(region: Region?)
    case pa(region: Region?)
    case pl(region: Region?)
    case ps(region: Region?)
    case pt(region: Region?)
    case qu(region: Region?)
    case ro(region: Region?)
    case ru(region: Region?)
    case sa(region: Region?)
    case se(region: Region?)
    case sk(region: Region?)
    case sl(region: Region?)
    case sq(region: Region?)
    case sr(region: Region?)
    case sv(region: Region?)
    case sw(region: Region?)
    case syr(region: Region?)
    case ta(region: Region?)
    case te(region: Region?)
    case th(region: Region?)
    case tl(region: Region?)
    case tn(region: Region?)
    case tr(region: Region?)
    case tt(region: Region?)
    case ts
    case uk(region: Region?)
    case ur(region: Region?)
    case uz(region: Region?)
    case vi(region: Region?)
    case xh(region: Region?)
    case zh(region: Region?)
    case zu(region: Region?)

    enum Region: Equatable {
        case standard(code: String)
        case withScript(code: String, script: Script)
        case withChineseVariant(code: String, variant: ChineseVariant)
        case withSamiDialect(code: String, dialect: SamiDialect)
    }

    enum Script: String {
        case latin = "Latin"
        case cyrillic = "Cyrillic"
    }

    enum ChineseVariant: String {
        case simplified = "Simplified"
        case traditional = "Traditional"
    }

    enum SamiDialect: String {
        case northern, lule, southern, inari, skolt
    }
    
    var rawValueShort: String {
        switch self {
        case .af: return "af"
        case .ar: return "ar"
        case .az: return "az"
        case .be: return "be"
        case .bg: return "bg"
        case .bs: return "bs"
        case .ca: return "ca"
        case .cs: return "cs"
        case .cy: return "cy"
        case .da: return "da"
        case .de: return "de"
        case .dv: return "dv"
        case .el: return "el"
        case .en: return "en"
        case .eo: return "eo"
        case .es: return "es"
        case .et: return "et"
        case .eu: return "eu"
        case .fa: return "fa"
        case .fi: return "fi"
        case .fo: return "fo"
        case .fr: return "fr"
        case .gl: return "gl"
        case .gu: return "gu"
        case .he: return "he"
        case .hi: return "hi"
        case .hr: return "hr"
        case .hu: return "hu"
        case .hy: return "hy"
        case .id: return "id"
        case .is: return "is"
        case .it: return "it"
        case .ja: return "ja"
        case .ka: return "ka"
        case .kk: return "kk"
        case .kn: return "kn"
        case .ko: return "ko"
        case .kok: return "kok"
        case .ky: return "ky"
        case .lt: return "lt"
        case .lv: return "lv"
        case .mi: return "mi"
        case .mk: return "mk"
        case .mn: return "mn"
        case .mr: return "mr"
        case .ms: return "ms"
        case .mt: return "mt"
        case .nb: return "nb"
        case .nl: return "nl"
        case .nn: return "nn"
        case .ns: return "ns"
        case .pa: return "pa"
        case .pl: return "pl"
        case .ps: return "ps"
        case .pt: return "pt"
        case .qu: return "qu"
        case .ro: return "ro"
        case .ru: return "ru"
        case .sa: return "sa"
        case .se: return "se"
        case .sk: return "sk"
        case .sl: return "sl"
        case .sq: return "sq"
        case .sr: return "sr"
        case .sv: return "sv"
        case .sw: return "sw"
        case .syr: return "syr"
        case .ta: return "ta"
        case .te: return "te"
        case .th: return "th"
        case .tl: return "tl"
        case .tn: return "tn"
        case .tr: return "tr"
        case .tt: return "tt"
        case .ts: return "ts"
        case .uk: return "uk"
        case .ur: return "ur"
        case .uz: return "uz"
        case .vi: return "vi"
        case .xh: return "xh"
        case .zh: return "zh"
        case .zu: return "zu"
        }
    }
    
    var rawValue: String {
        func regionCode(_ region: Region?) -> String? {
            guard let region = region else { return nil }
            switch region {
            case .standard(let code):
                return code
            case .withScript(let code, _):
                return code
            case .withChineseVariant(let code, _):
                return code
            case .withSamiDialect(let code, _):
                return code
            }
        }

        let code: String
        let region: Region?

        switch self {
        case .af(let r): code = "af"; region = r
        case .ar(let r): code = "ar"; region = r
        case .az(let r): code = "az"; region = r
        case .be(let r): code = "be"; region = r
        case .bg(let r): code = "bg"; region = r
        case .bs(let r): code = "bs"; region = r
        case .ca(let r): code = "ca"; region = r
        case .cs(let r): code = "cs"; region = r
        case .cy(let r): code = "cy"; region = r
        case .da(let r): code = "da"; region = r
        case .de(let r): code = "de"; region = r
        case .dv(let r): code = "dv"; region = r
        case .el(let r): code = "el"; region = r
        case .en(let r): code = "en"; region = r
        case .eo: return "eo"
        case .es(let r): code = "es"; region = r
        case .et(let r): code = "et"; region = r
        case .eu(let r): code = "eu"; region = r
        case .fa(let r): code = "fa"; region = r
        case .fi(let r): code = "fi"; region = r
        case .fo(let r): code = "fo"; region = r
        case .fr(let r): code = "fr"; region = r
        case .gl(let r): code = "gl"; region = r
        case .gu(let r): code = "gu"; region = r
        case .he(let r): code = "he"; region = r
        case .hi(let r): code = "hi"; region = r
        case .hr(let r): code = "hr"; region = r
        case .hu(let r): code = "hu"; region = r
        case .hy(let r): code = "hy"; region = r
        case .id(let r): code = "id"; region = r
        case .is(let r): code = "is"; region = r
        case .it(let r): code = "it"; region = r
        case .ja(let r): code = "ja"; region = r
        case .ka(let r): code = "ka"; region = r
        case .kk(let r): code = "kk"; region = r
        case .kn(let r): code = "kn"; region = r
        case .ko(let r): code = "ko"; region = r
        case .kok(let r): code = "kok"; region = r
        case .ky(let r): code = "ky"; region = r
        case .lt(let r): code = "lt"; region = r
        case .lv(let r): code = "lv"; region = r
        case .mi(let r): code = "mi"; region = r
        case .mk(let r): code = "mk"; region = r
        case .mn(let r): code = "mn"; region = r
        case .mr(let r): code = "mr"; region = r
        case .ms(let r): code = "ms"; region = r
        case .mt(let r): code = "mt"; region = r
        case .nb(let r): code = "nb"; region = r
        case .nl(let r): code = "nl"; region = r
        case .nn(let r): code = "nn"; region = r
        case .ns(let r): code = "ns"; region = r
        case .pa(let r): code = "pa"; region = r
        case .pl(let r): code = "pl"; region = r
        case .ps(let r): code = "ps"; region = r
        case .pt(let r): code = "pt"; region = r
        case .qu(let r): code = "qu"; region = r
        case .ro(let r): code = "ro"; region = r
        case .ru(let r): code = "ru"; region = r
        case .sa(let r): code = "sa"; region = r
        case .se(let r): code = "se"; region = r
        case .sk(let r): code = "sk"; region = r
        case .sl(let r): code = "sl"; region = r
        case .sq(let r): code = "sq"; region = r
        case .sr(let r): code = "sr"; region = r
        case .sv(let r): code = "sv"; region = r
        case .sw(let r): code = "sw"; region = r
        case .syr(let r): code = "syr"; region = r
        case .ta(let r): code = "ta"; region = r
        case .te(let r): code = "te"; region = r
        case .th(let r): code = "th"; region = r
        case .tl(let r): code = "tl"; region = r
        case .tn(let r): code = "tn"; region = r
        case .tr(let r): code = "tr"; region = r
        case .tt(let r): code = "tt"; region = r
        case .ts: return "ts"
        case .uk(let r): code = "uk"; region = r
        case .ur(let r): code = "ur"; region = r
        case .uz(let r): code = "uz"; region = r
        case .vi(let r): code = "vi"; region = r
        case .xh(let r): code = "xh"; region = r
        case .zh(let r): code = "zh"; region = r
        case .zu(let r): code = "zu"; region = r
        }

        if let regionStr = regionCode(region) {
            return "\(code)-\(regionStr)"
        } else {
            return code
        }
    }

    static func from(_ code: String) -> Language? {
        let components = code.split(separator: "-").map(String.init)
        guard !components.isEmpty else { return nil }

        let languageCode = components[0]
        let regionCode = components.count > 1 ? components[1] : nil

        let region: Region? = {
            switch languageCode {
            case "az":
                if regionCode == "AZ" {
                    // Ambíguo entre Latin e Cyrillic – você pode ajustar com regras extras se quiser diferenciar
                    return .withScript(code: "AZ", script: .latin)
                }
            case "zh":
                if let rc = regionCode {
                    switch rc {
                    case "CN", "SG": return .withChineseVariant(code: rc, variant: .simplified)
                    case "TW", "HK", "MO": return .withChineseVariant(code: rc, variant: .traditional)
                    default: return .standard(code: rc)
                    }
                }
            case "se":
                if let rc = regionCode {
                    switch rc {
                    case "FI": return .withSamiDialect(code: "FI", dialect: .northern)
                    case "NO": return .withSamiDialect(code: "NO", dialect: .northern)
                    case "SE": return .withSamiDialect(code: "SE", dialect: .northern)
                    default: return .standard(code: rc)
                    }
                }
            case "sr":
                if regionCode == "BA" || regionCode == "SP" {
                    return .withScript(code: regionCode!, script: .latin) // default to Latin
                }
            case "uz":
                if regionCode == "UZ" {
                    return .withScript(code: "UZ", script: .latin)
                }
            default:
                if let rc = regionCode {
                    return .standard(code: rc)
                }
            }
            return nil
        }()

        switch languageCode {
        case "af": return .af(region: region)
        case "ar": return .ar(region: region)
        case "az": return .az(region: region)
        case "be": return .be(region: region)
        case "bg": return .bg(region: region)
        case "bs": return .bs(region: region)
        case "ca": return .ca(region: region)
        case "cs": return .cs(region: region)
        case "cy": return .cy(region: region)
        case "da": return .da(region: region)
        case "de": return .de(region: region)
        case "dv": return .dv(region: region)
        case "el": return .el(region: region)
        case "en": return .en(region: region)
        case "eo": return .eo
        case "es": return .es(region: region)
        case "et": return .et(region: region)
        case "eu": return .eu(region: region)
        case "fa": return .fa(region: region)
        case "fi": return .fi(region: region)
        case "fo": return .fo(region: region)
        case "fr": return .fr(region: region)
        case "gl": return .gl(region: region)
        case "gu": return .gu(region: region)
        case "he": return .he(region: region)
        case "hi": return .hi(region: region)
        case "hr": return .hr(region: region)
        case "hu": return .hu(region: region)
        case "hy": return .hy(region: region)
        case "id": return .id(region: region)
        case "is": return .is(region: region)
        case "it": return .it(region: region)
        case "ja": return .ja(region: region)
        case "ka": return .ka(region: region)
        case "kk": return .kk(region: region)
        case "kn": return .kn(region: region)
        case "ko": return .ko(region: region)
        case "kok": return .kok(region: region)
        case "ky": return .ky(region: region)
        case "lt": return .lt(region: region)
        case "lv": return .lv(region: region)
        case "mi": return .mi(region: region)
        case "mk": return .mk(region: region)
        case "mn": return .mn(region: region)
        case "mr": return .mr(region: region)
        case "ms": return .ms(region: region)
        case "mt": return .mt(region: region)
        case "nb": return .nb(region: region)
        case "nl": return .nl(region: region)
        case "nn": return .nn(region: region)
        case "ns": return .ns(region: region)
        case "pa": return .pa(region: region)
        case "pl": return .pl(region: region)
        case "ps": return .ps(region: region)
        case "pt": return .pt(region: region)
        case "qu": return .qu(region: region)
        case "ro": return .ro(region: region)
        case "ru": return .ru(region: region)
        case "sa": return .sa(region: region)
        case "se": return .se(region: region)
        case "sk": return .sk(region: region)
        case "sl": return .sl(region: region)
        case "sq": return .sq(region: region)
        case "sr": return .sr(region: region)
        case "sv": return .sv(region: region)
        case "sw": return .sw(region: region)
        case "syr": return .syr(region: region)
        case "ta": return .ta(region: region)
        case "te": return .te(region: region)
        case "th": return .th(region: region)
        case "tl": return .tl(region: region)
        case "tn": return .tn(region: region)
        case "tr": return .tr(region: region)
        case "tt": return .tt(region: region)
        case "ts": return .ts
        case "uk": return .uk(region: region)
        case "ur": return .ur(region: region)
        case "uz": return .uz(region: region)
        case "vi": return .vi(region: region)
        case "xh": return .xh(region: region)
        case "zh": return .zh(region: region)
        case "zu": return .zu(region: region)
        default: return nil
        }
    }
}

extension Language: Equatable {
    static func ==(lhs: Language, rhs: Language) -> Bool {
        return lhs.rawValue == rhs.rawValue || lhs.rawValueShort == rhs.rawValueShort
    }
    
    func sameLanguageAndRegion(_ other: Language) -> Bool {
        return self.rawValue == other.rawValue
    }
    
    func sameLanguage(_ other: Language) -> Bool {
        return self.rawValueShort == other.rawValueShort
    }
}
