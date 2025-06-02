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
        print("Starting status monitor...")
        print("Monitoring log file at: \(claudeLogPath)")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkStatus()
        }
        checkStatus()
        print("Status monitor started")
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkStatus() {
        let newStatus = detectClaudeStatus()
        if newStatus != currentStatus {
            print("Status changed from \(currentStatus) to \(newStatus)")
            currentStatus = newStatus
            onStatusChange?(newStatus)
        }
    }
    
    private func detectClaudeStatus() -> ClaudeStatus {
        // First check if claude process is running
        if !isClaudeProcessRunning() {
            return .idle
        }
        
        guard FileManager.default.fileExists(atPath: claudeLogPath) else {
            return .idle
        }
        
        do {
            let logContent = try String(contentsOfFile: claudeLogPath, encoding: .utf8)
            let lines = logContent.components(separatedBy: .newlines)
            let recentLines = lines.suffix(10) // Only check last 10 lines for more recent status
            
            // Check for idle status first (most recent wins)
            for line in recentLines.reversed() {
                if line.contains("idle") || 
                   line.contains("completed") ||
                   line.contains("Task completed") {
                    return .idle
                }
            }
            
            // Then check for waiting permission
            for line in recentLines.reversed() {
                if line.contains("Waiting for user permission") || 
                   line.contains("requires approval") ||
                   line.contains("confirm") {
                    return .waitingForPermission
                }
            }
            
            // Finally check for executing
            for line in recentLines.reversed() {
                if line.contains("Executing") || 
                   line.contains("Running") ||
                   line.contains("Processing") ||
                   line.contains("Working on") {
                    return .executing
                }
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