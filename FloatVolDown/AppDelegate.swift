import UIKit
import Foundation

// 悬浮拖动按钮类，直接写在这个文件里，不再单独文件
class FloatDragBtn: UIView {
    var onTap: (()->Void)?
    private var startPoint: CGPoint = .zero
    private var isDrag = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.75)
        self.layer.cornerRadius = frame.width/2
        self.clipsToBounds = true
        
        let label = UILabel(frame: self.bounds)
        label.text = "−"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize:24, weight:.bold)
        label.textAlignment = .center
        self.addSubview(label)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        self.addGestureRecognizer(pan)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    @objc func tapAction(){
        if !isDrag {
            onTap?()
        }
    }
    @objc func panAction(_ g:UIPanGestureRecognizer){
        guard let w = superview else {return}
        let p = g.translation(in: w)
        if g.state == .began {
            startPoint = center
            isDrag = false
        }else if g.state == .changed {
            center = CGPoint(x: startPoint.x + p.x, y: startPoint.y + p.y)
            // 边界吸附
            if center.x < 25 { center.x = 25 }
            if center.x > w.bounds.width - 25 { center.x = w.bounds.width - 25 }
            if center.y < 60 { center.y = 60 }
            if center.y > w.bounds.height - 120 { center.y = w.bounds.height - 120 }
            let dx = abs(p.x), dy = abs(p.y)
            if dx>8 || dy>8 { isDrag = true }
        }
    }
}

// 调用私有GSEvent模拟音量-实体按键
private func sendVolumeDownKeyPress() {
    typealias GSEventCreate = @convention(c) (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> UnsafeMutableRawPointer
    typealias GSEventSend = @convention(c) (UnsafeMutableRawPointer) -> Void
    typealias GSEventRelease = @convention(c) (UnsafeMutableRawPointer) -> Void

    guard let gsBundle = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY) else { return }
    defer { dlclose(gsBundle) }
    guard let create = dlsym(gsBundle, "GSEventCreate") else { return }
    guard let send = dlsym(gsBundle, "GSEventSend") else { return }
    guard let release = dlsym(gsBundle, "GSEventRelease") else { return }

    let createFn = unsafeBitCast(create, to: GSEventCreate.self)
    let sendFn = unsafeBitCast(send, to: GSEventSend.self)
    let releaseFn = unsafeBitCast(release, to: GSEventRelease.self)

    // 音量减按键 GSEvent 参数
    let event = createFn(6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 104, 0, 0, 0, 0, 0, 0)
    sendFn(event)
    releaseFn(event)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var floatBtn: FloatDragBtn!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        // 悬浮球 50x50
        floatBtn = FloatDragBtn(frame: CGRect(x: UIScreen.main.bounds.width - 70, y: 320, width:50, height:50))
        floatBtn.onTap = {
            sendVolumeDownKeyPress()
        }
        window?.addSubview(floatBtn)
        return true
    }
}