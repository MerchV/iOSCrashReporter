import Foundation
import SystemConfiguration
import UIKit

public class CrashReporter: NSObject {

    public static var ENDPOINT: URL?

    override public init() {
        guard CrashReporter.ENDPOINT != nil else { fatalError("Set CrashReporter.ENDPOINT first.") }
        NSSetUncaughtExceptionHandler { (exception:NSException) in CrashReporter.prepareReport(CrashReporter.prepareExceptionStackTrace(exception: exception)) }
        signal(EXC_BREAKPOINT) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("EXC_BREAKPOINT")) }
        signal(EXC_CRASH) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("EXC_CRASH")) }
        signal(EXC_BAD_ACCESS) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("EXC_BAD_ACCESS")) }
        signal(EXC_BAD_INSTRUCTION) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("EXC_BAD_INSTRUCTION")) }
        signal(SIGINT) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGINT")) }
        signal(SIGABRT) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGABRT")) }
        signal(SIGKILL) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGKILL")) }
        signal(SIGTRAP) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGTRAP")) }
        signal(SIGBUS) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGBUS")) }
        signal(SIGSEGV) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGSEGV")) }
        signal(SIGHUP) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGHUP")) }
        signal(SIGTERM) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGTERM")) }
        signal(SIGILL) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGILL")) }
        signal(SIGFPE) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGFPE")) }
        signal(SIGPIPE) { (i:Int32) in CrashReporter.prepareReport(CrashReporter.prepareSignalStackTrace("SIGPIPE")) }
        // Some other signal names:
        // EXC_I386_INVOP TARGET_EXC_BAD_ACCESS EXC_ARM_BREAKPOINT
    }


    static private var signalReportWasSent = false // Signals occur repeatedly, and we only want to send one crash report

    static private func prepareSignalStackTrace(_ signal: String) -> String {
        var threadStackTrace = ""
        threadStackTrace.append("Signal: ")
        threadStackTrace.append(signal)
        threadStackTrace.append("\n\n")
        _ = Thread.callStackSymbols.map({ threadStackTrace.append("\($0)\n") })
        return threadStackTrace
    }

    static private func prepareExceptionStackTrace(exception: NSException) -> String {
        var exceptionStackTrace = ""
        exceptionStackTrace.append("\(exception.name)")
        exceptionStackTrace.append("\n\n")
        exceptionStackTrace.append("\(exception.reason ?? "")")
        exceptionStackTrace.append("\n\n")
        exceptionStackTrace.append(exceptionStackTrace)
        _ = exception.callStackSymbols.map({ exceptionStackTrace.append("\($0)\n") })
        return exceptionStackTrace
    }

    static private func prepareReport(_ stackTrace: String) {
        if signalReportWasSent == true {
            return // Avoid sending multiple signal reports
        }
        signalReportWasSent = true
        let bundleName = "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleName")!)"
        let subject = "\(bundleName) crash! 💥"
        var body = ""
        var uuid = ""
        if let existingUUID = UserDefaults.standard.value(forKey: "CrashReporterUUID") as? String {
            uuid = existingUUID
        } else {
            uuid = UUID().uuidString
            UserDefaults.standard.set(uuid, forKey: "CrashReporterUUID")
            UserDefaults.standard.synchronize()
        }
        body.append("User: ")
        body.append(uuid)
        body.append("\n")
        body.append(prepareDeviceDetails())
        body.append("\n\n")
        body.append(stackTrace)
        CrashReporter.sendReport(subject: subject, body: body)
    }

    static private func prepareDeviceDetails() -> String {
        var size : size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let platform = String(cString: machine)
        let product = ModelLookup.getProduct(platform: .iOS, model: platform)

        var subject = ""
        subject.append("Bundle identifier: ")
        subject.append(Bundle.main.bundleIdentifier ?? "")
        subject.append("\n")
        subject.append("Version: ")
        let versionString = "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)"
        subject.append(versionString)
        subject.append("\n")
        subject.append("Build: ")
        let buildString = "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)"
        subject.append(buildString)
        subject.append("\n")
        subject.append("Model: ")
        subject.append(platform)
        subject.append("\n")
        subject.append("Product: ")
        subject.append(product)
        subject.append("\n")
        subject.append("System: ")
        subject.append("iOS ")
        subject.append("\(UIDevice.current.systemVersion)")
        return subject

    }


    static private func sendReport(subject: String, body: String) {
        var parameters = ""
        parameters.append("&subject=\(subject)")
        parameters.append("&body=\(body)")
        let request = NSMutableURLRequest(url: ENDPOINT!)
        request.httpMethod = "POST"
        let body = parameters.data(using: String.Encoding.utf8)
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 3))
    }


}
