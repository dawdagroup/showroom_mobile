import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let printChannel = FlutterMethodChannel(name: "com.example.showroom_manager/print",
                                          binaryMessenger: controller.binaryMessenger)
    printChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      if call.method == "printPdf" {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing filePath parameter", details: nil))
          return
        }
        self.printPdf(filePath: filePath, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func printPdf(filePath: String, result: @escaping FlutterResult) {
    let fileURL = URL(fileURLWithPath: filePath)
    
    guard FileManager.default.fileExists(atPath: filePath) else {
      result(FlutterError(code: "FILE_NOT_FOUND", message: "PDF file not found", details: nil))
      return
    }
    
    if UIPrintInteractionController.isPrintingAvailable {
      let printController = UIPrintInteractionController.shared
      
      let printInfo = UIPrintInfo(dictionary: nil)
      printInfo.outputType = .general
      printInfo.jobName = "PDF Document"
      printController.printInfo = printInfo
      
      printController.printingItem = fileURL
      
      printController.present(animated: true) { (controller, completed, error) in
        if let error = error {
          result(FlutterError(code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
        } else {
          result("Print dialog presented")
        }
      }
    } else {
      result(FlutterError(code: "PRINT_NOT_AVAILABLE", message: "Printing not available", details: nil))
    }
  }
}
