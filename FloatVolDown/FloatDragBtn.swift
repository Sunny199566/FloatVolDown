import UIKit
import Foundation

class ViewController: UIViewController {
    
    var daemonPID: pid_t = -1
    
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
        guard daemonPID == -1 else { return }
        guard let exePath = Bundle.main.path(forResource: "hud_daemon", ofType: nil) else {
            print("找不到 hud_daemon")
            return
        }
        
        var attr: posix_spawnattr_t?
        posix_spawnattr_init(&attr)
        var fileActions: posix_spawn_file_actions_t?
        posix_spawn_file_actions_init(&fileActions)
        
        let argv: [UnsafeMutablePointer<CChar>?] = [
            strdup(exePath),
            nil
        ]
        defer {
            argv.forEach { free($0) }
        }
        
        var pid: pid_t = 0
        let ret = posix_spawn(&pid, exePath, &fileActions, &attr, argv, environ)
        if ret == 0 {
            daemonPID = pid
            print("daemon启动成功 pid=\(pid)")
        } else {
            print("启动失败 err=\(ret)")
        }
        posix_spawnattr_destroy(&attr)
        posix_spawn_file_actions_destroy(&fileActions)
    }
    
    @objc func stopTap() {
        guard daemonPID > 0 else { return }
        kill(daemonPID, SIGTERM)
        daemonPID = -1
    }
}