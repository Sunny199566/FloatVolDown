import UIKit

// 私有GraphicsServices
private func GSSendEvent(_ event: UnsafeRawPointer) -> Int32 {
    typealias Func = @convention(c) (UnsafeRawPointer) -> Int32
    guard let f = dlsym(dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY), "GSSendEvent") else {
        return -1
    }
    let call = unsafeBitCast(f, to: Func.self)
    return call(event)
}

// 构造音量减 GSEvent
private func sendVolumeDownKeyEvent() {
    // keyCode: 0x49 = 音量减，iOS固定
    let keyCode: UInt16 = 0x49
    // GSEvent 按键事件构造，按下+松开（模拟一次单击按键）
    var eventData: [UInt8] = Array(repeating: 0, count: 256)
    // 简化可用构造（巨魔17.0实测可用）
    let ptr = UnsafeMutableRawPointer(&eventData)
    // 事件类型：按键
    ptr.storeBytes(of: 0x101, as: UInt32.self)
    ptr.advanced(by: 0x14).storeBytes(of: keyCode, as: UInt16.self)
    ptr.advanced(by: 0x18).storeBytes(of: 1, as: UInt32.self) // 按下
    GSSendEvent(ptr)
    usleep(30000)
    ptr.advanced(by: 0x18).storeBytes(of: 0, as: UInt32.self) // 松开
    GSSendEvent(ptr)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var floatWindow: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 悬浮窗
        floatWindow = UIWindow(frame: CGRect(x: 260, y: 360, width: 60, height: 60))
        floatWindow?.windowLevel = .alert + 10
        floatWindow?.backgroundColor = .clear
        floatWindow?.isHidden = false

        let btn = FloatDragBtn(frame: floatWindow!.bounds)
        btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        btn.layer.cornerRadius = 30
        btn.setTitle("−", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize:24, weight: .bold)
        btn.addTarget(self, action: #selector(onTap), for: .touchUpInside)

        floatWindow?.rootViewController = UIViewController()
        floatWindow?.rootViewController?.view.addSubview(btn)
        return true
    }

    @objc private func onTap() {
        sendVolumeDownKeyEvent()
    }
}
