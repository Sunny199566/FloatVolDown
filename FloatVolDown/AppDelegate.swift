import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var floatBtn: FloatDragBtn!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        floatBtn = FloatDragBtn(frame: CGRect(x: 30, y: 300, width: 60, height: 60))
        floatBtn.addTarget(self, action: #selector(sendVolumeDownEvent), for: .touchUpInside)
        window?.addSubview(floatBtn)
        return true
    }
    
    @objc func sendVolumeDownEvent() {
        // GSEvent 模拟实体音量减按键 (0x49=vol-,0x4A=vol+)
        let keyCode: UInt16 = 0x49
        sendGSKeyEvent(keyCode: keyCode, down: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            self.sendGSKeyEvent(keyCode: keyCode, down: false)
        }
    }
    
    private func sendGSKeyEvent(keyCode: UInt16, down: Bool) {
        guard let GSCreateEvent = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY) else { return }
        typealias GSCreateEventFunc = @convention(c) (UInt32, UInt16, Bool, Double) -> UnsafeMutableRawPointer
        guard let createFunc = dlsym(GSCreateEvent, "GSCreateHIDEvent") else { return }
        let create = unsafeBitCast(createFunc, to: GSCreateEventFunc.self)
        let event = create(0x0006, keyCode, down, CACurrentMediaTime())
        
        typealias GSSendEventFunc = @convention(c) (UnsafeMutableRawPointer) -> Void
        guard let sendFunc = dlsym(GSCreateEvent, "GSSendEvent") else { return }
        let send = unsafeBitCast(sendFunc, to: GSSendEventFunc.self)
        send(event)
    }
}