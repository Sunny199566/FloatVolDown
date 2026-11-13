import UIKit

// MARK: GSEvent 私有API，iOS17.0 模拟音量减按键
typealias GSEventRef = UnsafeMutableRawPointer
@_silgen_name("_GSSendEvent")
func _GSSendEvent(_ event: GSEventRef) -> Void

func sendVolumeDownPress() {
    var data: [UInt8] = Array(repeating: 0, count: 128)
    // iOS17 音量按下事件码
    data[0x04] = 0x02
    data[0x0C] = 0x01
    data[0x10] = 0x10
    data[0x14] = 0x01
    let ptr = UnsafeMutableRawPointer(&data).assumingMemoryBound(to: UInt8.self)
    _GSSendEvent(ptr)
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var floatBtn: UIButton!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 悬浮窗口，层级高于普通App
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowLevel = .alert + 10
        window?.isHidden = false
        
        floatBtn = UIButton(frame: CGRect(x: 20, y: 350, width: 60, height: 60))
        floatBtn.backgroundColor = UIColor.systemBlue
        floatBtn.layer.cornerRadius = 30
        floatBtn.setTitle("−", for: .normal)
        floatBtn.setTitleColor(.white, for: .normal)
        floatBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        floatBtn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        // 拖拽手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragMove(_:)))
        floatBtn.addGestureRecognizer(pan)
        
        window?.rootViewController = UIViewController()
        window?.rootViewController?.view.addSubview(floatBtn)
        return true
    }
    
    @objc func tapAction() {
        sendVolumeDownPress()
    }
    
    @objc func dragMove(_ g: UIPanGestureRecognizer) {
        guard let btn = g.view else { return }
        let trans = g.translation(in: window)
        btn.center = CGPoint(x: btn.center.x + trans.x, y: btn.center.y + trans.y)
        g.setTranslation(.zero, in: window)
    }
}

// 程序入口，替代 @main
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegate.self)
)