// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Button {
    /// Повторить
    internal static let retry = L10n.tr("Localizable", "button.retry", fallback: "Повторить")
  }
  internal enum Error {
    /// Ошибка обработки данных: %@
    internal static func decodingError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "error.decoding-error", String(describing: p1), fallback: "Ошибка обработки данных: %@")
    }
    /// Localizable.strings
    ///   AutodocTest
    /// 
    ///   Created by Roman Komarov on 29.09.2026.
    internal static let invalidUrl = L10n.tr("Localizable", "error.invalid-url", fallback: "Неверный URL адрес.")
    /// Ошибка сети: %@
    internal static func networkError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "error.network-error", String(describing: p1), fallback: "Ошибка сети: %@")
    }
    /// Сервер не вернул данных.
    internal static let noData = L10n.tr("Localizable", "error.no-data", fallback: "Сервер не вернул данных.")
    /// Неожиданный статус-код: %@
    internal static func unexpectedStatusCode(_ p1: Any) -> String {
      return L10n.tr("Localizable", "error.unexpected-status-code", String(describing: p1), fallback: "Неожиданный статус-код: %@")
    }
    /// Произошла неизвестная ошибка.
    internal static let unknown = L10n.tr("Localizable", "error.unknown", fallback: "Произошла неизвестная ошибка.")
  }
  internal enum NewsList {
    /// В данный момент ничего нет
    internal static let empty = L10n.tr("Localizable", "news-list.empty", fallback: "В данный момент ничего нет")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
