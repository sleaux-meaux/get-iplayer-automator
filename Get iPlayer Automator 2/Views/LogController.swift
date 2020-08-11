//
//  LogController.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 8/5/20.
//

import Foundation
import Cocoa

public class LogController {

    let logFilePath: URL
    var log: [String] = []
    let fh: FileHandle?

    public init() {

        logFilePath = FileManager.default.applicationSupportDirectory.appendingPathComponent("log.txt")
        FileManager.default.createFile(atPath: logFilePath.path, contents: nil, attributes: nil)
        fh = FileHandle(forWritingAtPath: logFilePath.path)
        fh?.seekToEndOfFile()

        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "unknown"
        print("Get iPlayer Automator %@ Initialized.", version)
        let initialLog = "Get iPlayer Automator \(version) Initialized."
        addToLog(initialLog)

        NotificationCenter.default.addObserver(self, selector: #selector(addToLogNotification), name: Notification.Name("AddToLog"), object: nil)
    }
    
    deinit {
        do {
            try fh?.close()
        } catch {
            // Nothing to do
        }
        
    }
}

extension LogController: Logging {

    public func addToLog(_ string: String) {
        self.addToLog(string, sender: nil)
    }
    
    public func addToLog(_ string: String, sender: Any?) {

        var msg = ""
        
        if let sender = sender {
            msg += "[\(sender)] "
        }
        
        msg += string + "\n"

        if let data = msg.data(using: .utf8) {
            fh?.write(data)
        }
        
        log.append(msg)
    }

//    //Scroll log to bottom only if it is visible.
//    if (self.window.visible) {
//    BOOL shouldAutoScroll = ((int)NSMaxY([self.log bounds]) == (int)NSMaxY([self.log visibleRect]));
//    if (shouldAutoScroll) {
//    [self.log scrollToEndOfDocument:nil];
//    }
//    }
     
    @objc public func addToLogNotification(_ note: NSNotification) {
        if let logMessage = note.userInfo?["message"] as? String {
            self.addToLog(logMessage, sender: note.object)
        }
    }

//    - (IBAction)copyLog:(id)sender
//{
//    NSString *unattributedLog = _log.string;
//    NSPasteboard *pb = [NSPasteboard generalPasteboard];
//    NSArray *types = @[NSStringPboardType];
//    [pb declareTypes:types owner:self];
//    [pb setString:unattributedLog forType:NSStringPboardType];
//}

}
