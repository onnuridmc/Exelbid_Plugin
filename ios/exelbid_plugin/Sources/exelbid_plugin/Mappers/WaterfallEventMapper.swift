import ExelBidSDK
import Foundation

/// Encodes an `ExelBidSDK.EBWaterfallEvent` into a Dart-friendly map sent under
/// the `"waterfall"` key of an `onWaterfall` event. The shape mirrors the
/// `EBWaterfallEvent` sealed class on the Dart side.
enum WaterfallEventMapper {
    static func encode(_ event: EBWaterfallEvent) -> [String: Any] {
        switch event {
        case .fetching:
            return ["type": "fetching"]
        case let .fetched(networks):
            return ["type": "fetched", "networks": networks]
        case let .trying(network, unitId, position, total):
            return [
                "type": "trying",
                "network": network,
                "unitId": unitId,
                "position": position,
                "total": total,
            ]
        case let .won(network, position, latency):
            return [
                "type": "won",
                "network": network,
                "position": position,
                "latencyMs": Int(latency * 1000),
            ]
        case let .lost(network, position, reason):
            return [
                "type": "lost",
                "network": network,
                "position": position,
                "reason": reasonString(reason),
            ]
        case .noFill:
            return ["type": "noFill"]
        }
    }

    private static func reasonString(_ reason: EBWaterfallFailReason) -> String {
        switch reason {
        case .adapterNotRegistered:
            return "adapterNotRegistered"
        case let .loadFailed(error):
            return "loadFailed: \(error.localizedDescription)"
        case let .timeout(seconds):
            return "timeout \(seconds)s"
        case .cancelled:
            return "cancelled"
        }
    }
}
