import Foundation

// 启动守护进程
func startHUD() {
    guard let daemonPath = Bundle.main.path(forResource: "hud_daemon", ofType: nil) else {
        print("找不到hud_daemon")
        return
    }
    let pathC = daemonPath.cString(using: .utf8)!
    let pid = fork()
    if pid == 0 {
        execl(pathC, "hud_daemon", nil)
        exit(0)
    }
}

// 关闭悬浮，杀掉进程
func stopHUD() {
    system("pkill -9 hud_daemon")
}

// 在viewDidLoad里面添加两个按钮，打开App就能看到
override func viewDidLoad() {
    super.viewDidLoad()
    
    let startBtn = UIButton(frame: CGRect(x:40, y:140, width:130, height:52))
    startBtn.setTitle("✅ 开启全局悬浮", for: .normal)
    startBtn.backgroundColor = .systemBlue
    startBtn.layer.cornerRadius = 10
    startBtn.addTarget(self, action: #selector(startTap), for: .touchUpInside)
    self.view.addSubview(startBtn)
    
    let stopBtn = UIButton(frame: CGRect(x:190, y:140, width:130, height:52))
    stopBtn.setTitle("❌ 关闭悬浮", for: .normal)
    stopBtn.backgroundColor = .systemRed
    stopBtn.layer.cornerRadius = 10
    stopBtn.addTarget(self, action: #selector(stopTap), for: .touchUpInside)
    self.view.addSubview(stopBtn)
}

@objc func startTap() {
    startHUD()
}
@objc func stopTap() {
    stopHUD()
}