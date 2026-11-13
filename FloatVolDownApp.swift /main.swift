import UIKit

// 私有函数声明，不依赖头文件
@_cdecl("_GSSendEvent")
func _GSSendEvent(_ event: UnsafeRawPointer)

func sendVolumeDownKeyPress() {
    var buf: [UInt8] = Array(repeating: 0, count: 64)
    buf[0] = 0x2101 // iOS17音量down事件type
    buf[1] = 1       // 按下
    _GSSendEvent(buf.withUnsafeBufferPointer { $0.baseAddress! })
    usleep(30000)
    buf[1] = 0       // 松开
    _GSSendEvent(buf.withUnsafeBufferPointer { $0.baseAddress! })
}

class FloatBallView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        layer.cornerRadius = frame.width / 2
        isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
        
        // 拖拽悬浮球
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        addGestureRecognizer(pan)
    }
    required init?(coder: NSCoder) { nil }
    
    @objc func onTap() {
        sendVolumeDownKeyPress()
    }
    
    @objc func onPan(_ g: UIPanGestureRecognizer) {
        guard let v = g.view else { return }
        let pt = g.translation(in: self.superview)
        v.center = CGPoint(x: v.center.x + pt.x, y: v.center.y + pt.y)
        g.setTranslation(.zero, in: self.superview)
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var floatBall: FloatBallView!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        floatBall = FloatBallView(frame: CGRect(x: 30, y: 300, width: 55, height: 55))
        window?.addSubview(floatBall)
        return true
    }
}
