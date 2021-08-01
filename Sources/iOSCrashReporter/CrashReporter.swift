//
//  HealthManager.swift
//

import Foundation
import SystemConfiguration
//import UIKit

public class CrashReporter: NSObject {

    ////////////////////////////////////////
    // CONFIGURATION
    ////////////////////////////////////////

    // STEP 1

    /*
        Place a PHP file, such as the one below, on a publicly visible web host. This PHP file will receive the subject and body parameters from the POST request and send those to the e-mail address specified.
     */

    /*
         <?php
         $subject = $_POST['subject'];
         $body = $_POST['body'];
         mail("YOU@EXAMPLE.COM", $subject, $body)
         ?>
     */


    // STEP 2

    /*
        Specify the URL to the publicly visible PHP file.
    */
    public static var ENDPOINT: URL?


    override public init() {
        guard CrashReporter.ENDPOINT != nil else { fatalError("Set CrashReporter.ENDPOINT first.") }
        NSSetUncaughtExceptionHandler { (exception:NSException) in CrashReporter.prepareReport(exception: exception, signal: nil) }
        signal(EXC_BREAKPOINT) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "EXC_BREAKPOINT") }
        signal(EXC_CRASH) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "EXC_CRASH") }
        signal(EXC_BAD_ACCESS) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "EXC_BAD_ACCESS") }
        signal(EXC_BAD_INSTRUCTION) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "EXC_BAD_INSTRUCTION") }
        signal(SIGINT) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGINT") }
        signal(SIGABRT) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGABRT") }
        signal(SIGKILL) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGKILL") }
        signal(SIGTRAP) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGTRAP") }
        signal(SIGBUS) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGBUS") }
        signal(SIGSEGV) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGSEGV") }
        signal(SIGHUP) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGHUP") }
        signal(SIGTERM) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGTERM") }
        signal(SIGILL) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGILL") }
        signal(SIGFPE) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGFPE") }
        signal(SIGPIPE) { (i:Int32) in CrashReporter.prepareReport(exception: nil, signal: "SIGPIPE") }
        // Some other signal names:
        // EXC_I386_INVOP TARGET_EXC_BAD_ACCESS EXC_ARM_BREAKPOINT
    }


    static var signalReportWasSent = false // Signals occur repeatedly, and we only want to send one crash report

    static func prepareReport(exception: NSException?, signal: String?) {
        if signal != nil && signalReportWasSent == true {
            return // Avoid sending multiple signal reports
        }
        signalReportWasSent = true
        let subject = CrashReporter.prepareSubject()
        var body = ""
        var uuid = ""
        if let existingUUID = UserDefaults.standard.value(forKey: "HealthUUID") as? String {
            uuid = existingUUID
        } else {
            uuid = UUID().uuidString
            UserDefaults.standard.set(uuid, forKey: "HealthUUID")
            UserDefaults.standard.synchronize()
        }
        body.append(uuid)
        body.append("\n\n")
        if exception != nil { // This is an exception crash
            var exceptionStackTrace = ""
            for stackItemString in exception!.callStackSymbols {
                exceptionStackTrace.append("\(stackItemString)\n")
            }
            body.append("\(exception!.name)")
            body.append("\n\n")
            body.append("\(exception!.reason ?? "")")
            body.append("\n\n")
            body.append(exceptionStackTrace)
        } else if signal != nil { // This is a signal crash
            var threadStackTrace = ""
            Thread.callStackSymbols.forEach({ (string:String) in
                threadStackTrace.append("\(string)\n")
            })
            body.append(signal!)
            body.append("\n\n")
            body.append(threadStackTrace)
        }
        var parameters = ""
        parameters.append("&subject=\(subject)")
        parameters.append("&body=\(body)")
        CrashReporter.sendReport(parameters: parameters)
    }




    // Produces a string in this format:
    // <bundle id> | <bundle version> <bundle build number> | <model name> | <iOS version>
    // E.g., com.example.MyApp | 2.1 (1) | iPad mini 1 | 9.3.5
    // This will be used for the subject of the e-mail of the crash report.
    static private func prepareSubject() -> String {
        var size : size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let platform = String(cString: machine)
        let product = CrashReporter.modelMapping(model: platform)

        var subject = ""
        subject.append(Bundle.main.bundleIdentifier ?? "")
        subject.append(" | ")
        let versionString = "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)"
        let buildString = "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)"
        let version = "\(versionString) (\(buildString))"
        subject.append("\(version)")
        subject.append(" | ")
        subject.append(product)
        subject.append(" | ")
//        subject.append("\(UIDevice.current.systemVersion)")
        return subject

    }

    static private func modelMapping(model: String) -> String {
        switch model {
        default:
            return model
        }
    }


    // Performs the HTTP POST request to the PHP file specified above.
    static func sendReport(parameters: String) {
        let request = NSMutableURLRequest(url: ENDPOINT!)
        request.httpMethod = "POST"
        let body = parameters.data(using: String.Encoding.utf8)
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 3))
    }


}
