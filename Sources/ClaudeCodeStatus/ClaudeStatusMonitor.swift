import Foundation
import Combine

enum ClaudeStatus {
    case idle
    case waitingForPermission
    case executing
}

class ClaudeStatusMonitor {
    var onStatusChange: ((ClaudeStatus) -> Void)?
    private var timer: Timer?
    private var currentStatus: ClaudeStatus = .idle
    private let claudeLogPath: String
    
    init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        self.claudeLogPath = homeDirectory.appendingPathComponent(".claude/logs/claude.log").path
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkStatus()
        }
        checkStatus()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkStatus() {
        let newStatus = detectClaudeStatus()
        if newStatus != currentStatus {
            currentStatus = newStatus
            onStatusChange?(newStatus)
        }
    }
    
    private func detectClaudeStatus() -> ClaudeStatus {
        guard FileManager.default.fileExists(atPath: claudeLogPath) else {
            return .idle
        }
        
        do {
            let logContent = try String(contentsOfFile: claudeLogPath, encoding: .utf8)
            let lines = logContent.components(separatedBy: .newlines)
            let recentLines = lines.suffix(50)
            
            for line in recentLines.reversed() {
                if line.contains("Waiting for user permission") || 
                   line.contains("requires approval") ||
                   line.contains("confirm") {
                    return .waitingForPermission
                }
                
                if line.contains("Executing") || 
                   line.contains("Running") ||
                   line.contains("Processing") ||
                   line.contains("Working on") {
                    return .executing
                }
            }
            
            if isClaudeProcessRunning() {
                return .idle
            }
            
        } catch {
            print("Error reading log file: \(error)")
        }
        
        return .idle
    }
    
    private func isClaudeProcessRunning() -> Bool {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "pgrep -x claude"]
        task.launchPath = "/bin/bash"
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            return !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } catch {
            return false
        }
    }
}