import Foundation

/// Thread-safe registry mapping instance UUID → handle for full-screen ads.
/// Handles store their own SDK objects and channels; the registry only keeps a
/// strong reference so they stay alive until Dart calls `dispose`.
final class InstanceRegistry {
    static let shared = InstanceRegistry()

    private var handles: [String: AnyObject] = [:]
    private let lock = NSLock()

    private init() {}

    func register(_ handle: AnyObject, forId id: String) {
        lock.lock(); defer { lock.unlock() }
        handles[id] = handle
    }

    func handle(forId id: String) -> AnyObject? {
        lock.lock(); defer { lock.unlock() }
        return handles[id]
    }

    @discardableResult
    func remove(id: String) -> AnyObject? {
        lock.lock(); defer { lock.unlock() }
        return handles.removeValue(forKey: id)
    }
}
