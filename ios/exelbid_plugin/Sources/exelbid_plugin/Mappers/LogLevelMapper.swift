import ExelBidSDK

enum LogLevelMapper {
    static func from(rawValue: Int) -> LogLevel {
        LogLevel(rawValue: rawValue) ?? .warning
    }
}
