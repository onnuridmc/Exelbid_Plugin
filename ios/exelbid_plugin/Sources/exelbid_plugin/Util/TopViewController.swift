import UIKit

enum TopViewController {
    /// Walks the foregrounded scene's key window from rootViewController down
    /// through presented controllers / nav stacks / tab selections to find the
    /// view controller the SDK should present from.
    static func find() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first

        return topMost(from: keyWindow?.rootViewController)
    }

    private static func topMost(from controller: UIViewController?) -> UIViewController? {
        guard let controller = controller else { return nil }
        if let presented = controller.presentedViewController {
            return topMost(from: presented)
        }
        if let nav = controller as? UINavigationController {
            return topMost(from: nav.visibleViewController) ?? nav
        }
        if let tab = controller as? UITabBarController {
            return topMost(from: tab.selectedViewController) ?? tab
        }
        return controller
    }
}
