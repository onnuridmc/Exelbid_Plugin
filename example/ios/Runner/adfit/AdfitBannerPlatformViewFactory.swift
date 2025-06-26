import Flutter

class AdfitBannerPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AdfitBannerPlatformView(frame: frame,
                        viewIdentifier: viewId,
                        arguments: args,
                        binaryMessenger: messenger)
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
