# iOSCrashReporter

## DESCRIPTION

This package can be added to an iOS project to capture crashes (both signals and exceptions) and send a stack trace and other information as an HTTP POST to a PHP file which you control which in turn sends that information to your e-mail address.

## INSTALLATION
#### Swift Package Manager
```
.package(url: "https://github.com/MerchV/iOSCrashReporter ", from: "1.0.0")
```


## INSTRUCTIONS

Set up a PHP file (or some other web service to receive an HTTP POST) on a publicly visible web host. This is an example PHP file:

```
<?php
        $subject = $_POST['subject'];
        $body = $_POST['body'];
        mail("YOU@EXAMPLE.com", $subject, $body)
?>
```

This PHP file will receive the subject and body parameters sent in an HTTP POST request from the crash reporter. Then, the crash report is sent to the e-mail address specified using the Linux mail program. 


## CONFIGURATION

1. Import iOSCrashReporter
2. Set the URL to your PHP file to the static ENDPOINT variable on CrashReporter.
3. Initialize CrashReporter. You don't need to keep a reference to it.

# In AppDelegate:
```
import UIKit
import iOSCrashReporter // 1

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = CrashReporter(URL(string: "https://your-web-host.com/crash.php")!)
        return true
    }

}


```

## In a SwiftUI App:
```
import SwiftUI
import iOSCrashReporter

@main
struct MyApp: App {

    init() {
        _ = CrashReporter(URL(string: "https://your-web-host.com/crash.php")!)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



## TESTING
When testing for a crash, remember that the crash signal won't be captured while connected to the Xcode debugger. Run the app without being connected to Xcode to try a crash. Exception crashes will be reported while connected to the Xcode debugger.

Here's a way to cause a signal crash:
```
var a = [Int]()
_ = a[0]
```
        
Here's a way to cause an exception crash:
```
performSegue(withIdentifier: "ThisSegueDoesNotExist", sender: self)
```


## REPORTS

An e-mail for an exception crash will look like this:

```
Subject: com.merchv.CrashReporterDemo | 1.0 (1) | Simulator | 11.2
Body:
5554CD20-E10F-4AEB-9706-54600C54844C

NSExceptionName(_rawValue: NSInvalidArgumentException)

Receiver (<CrashReporterDemo.ViewController: 0x7fa39a307a60>) has no segue with identifier 'ThisSegueIdentifierDoesNotExist'

0   CoreFoundation                      0x0000000105f8a12b __exceptionPreprocess   171
1   libobjc.A.dylib                     0x000000010561ef41 objc_exception_throw   48
2   UIKit                               0x00000001065b33d0 -[UIViewController shouldPerformSegueWithIdentifier:sender:]   0
3   CrashReporterDemo                   0x0000000104c77320 _T017CrashReporterDemo14ViewControllerC014causeExceptionA0ySo8UIButtonCF   368
4   CrashReporterDemo                   0x0000000104c7745c _T017CrashReporterDemo14ViewControllerC014causeExceptionA0ySo8UIButtonCFTo   60
5   UIKit                               0x0000000106409972 -[UIApplication sendAction:to:from:forEvent:]   83
6   UIKit                               0x0000000106588c3c -[UIControl sendAction:to:forEvent:]   67
7   UIKit                               0x0000000106588f59 -[UIControl _sendActionsForEvents:withEvent:]   450
8   UIKit                               0x0000000106587e86 -[UIControl touchesEnded:withEvent:]   618
9   UIKit                               0x000000010647f807 -[UIWindow _sendTouchesForEvent:]   2807
10  UIKit                               0x0000000106480f2a -[UIWindow sendEvent:]   4124
11  UIKit                               0x0000000106424365 -[UIApplication sendEvent:]   352
12  UIKit                               0x0000000106d70a1d __dispatchPreprocessedEventFromEventQueue   2809
13  UIKit                               0x0000000106d73672 __handleEventQueueInternal   5957
14  CoreFoundation                      0x0000000105f2d101 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__   17
15  CoreFoundation                      0x0000000105fccf71 __CFRunLoopDoSource0   81
16  CoreFoundation                      0x0000000105f11a19 __CFRunLoopDoSources0   185
17  CoreFoundation                      0x0000000105f10fff __CFRunLoopRun   1279
18  CoreFoundation                      0x0000000105f10889 CFRunLoopRunSpecific   409
19  GraphicsServices                    0x000000010b8629c6 GSEventRunModal   62
20  UIKit                               0x00000001064085d6 UIApplicationMain   159
21  CrashReporterDemo                   0x0000000104c891b7 main   55
22  libdyld.dylib                       0x000000010a2a9d81 start   1
23  ???                                 0x0000000000000001 0x0   1
```

An e-mail for a signal crash will look like this:

```
Subject: com.merchv.CrashReporterDemo | 1.0 (1) | Simulator | 11.2
Body:
5554CD20-E10F-4AEB-9706-54600C54844C

SIGILL

0   CrashReporterDemo                   0x00000001087a6588 _T017CrashReporterDemo13HealthManagerC13prepareReportySo11NSExceptionCSg9exception_SSSg6signaltFZ   6072
1   CrashReporterDemo                   0x00000001087a71d4 _T017CrashReporterDemo13HealthManagerCACycfcys5Int32VcfU12_   84
2   CrashReporterDemo                   0x00000001087a71e9 _T017CrashReporterDemo13HealthManagerCACycfcys5Int32VcfU12_To   9
3   libsystem_platform.dylib            0x000000010e213f5a _sigtramp   26
4   ???                                 0x0000000000000000 0x0   0
5   libswiftSwiftOnoneSupport.dylib     0x000000010a972d79 _T0Sa9subscriptxSicfgSi_Tgq5   89
6   CrashReporterDemo                   0x00000001087a4499 _T017CrashReporterDemo14ViewControllerC011causeSignalA0ySo8UIButtonCF   41
7   CrashReporterDemo                   0x00000001087a44fc _T017CrashReporterDemo14ViewControllerC011causeSignalA0ySo8UIButtonCFTo   60
8   UIKit                               0x000000010b003972 -[UIApplication sendAction:to:from:forEvent:]   83
9   UIKit                               0x000000010b182c3c -[UIControl sendAction:to:forEvent:]   67
10  UIKit                               0x000000010b182f59 -[UIControl _sendActionsForEvents:withEvent:]   450
11  UIKit                               0x000000010b181e86 -[UIControl touchesEnded:withEvent:]   618
12  UIKit                               0x000000010b079807 -[UIWindow _sendTouchesForEvent:]   2807
13  UIKit                               0x000000010b07af2a -[UIWindow sendEvent:]   4124
14  UIKit                               0x000000010b01e365 -[UIApplication sendEvent:]   352
15  UIKit                               0x000000010b96aa1d __dispatchPreprocessedEventFromEventQueue   2809
16  UIKit                               0x000000010b96d672 __handleEventQueueInternal   5957
17  CoreFoundation                      0x0000000109a5a101 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__   17
18  CoreFoundation                      0x0000000109af9f71 __CFRunLoopDoSource0   81
19  CoreFoundation                      0x0000000109a3ea19 __CFRunLoopDoSources0   185
20  CoreFoundation                      0x0000000109a3dfff __CFRunLoopRun   1279
21  CoreFoundation                      0x0000000109a3d889 CFRunLoopRunSpecific   409
22  GraphicsServices                    0x000000010f38f9c6 GSEventRunModal   62
23  UIKit                               0x000000010b0025d6 UIApplicationMain   159
24  CrashReporterDemo                   0x00000001087b61b7 main   55
25  libdyld.dylib                       0x000000010ddddd81 start   1
```

## SYMBOLICATION

Crash report e-mails may contain stack traces with lines that look like these:

```
7 UIKit 0x28cdb6e3 <redacted> 230
8 UIKit 0x28f032d1 <redacted> 3080
9 UIKit 0x28f07285 <redacted> 1588
10 UIKit 0x28f1b83d <redacted> 36
11 UIKit 0x28f047b3 <redacted> 134
```

These lines may not show method names or anything useful. That's due to symbolication. The lines would need to be manually symbolicated. 
