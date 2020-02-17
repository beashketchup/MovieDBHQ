import MovieFramework
import MovieLibrary
import ReactiveSwift
import UIKit

@UIApplicationMain
internal final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  fileprivate let viewModel: AppDelegateViewModelType = AppDelegateViewModel()
  
  internal var rootController: MainViewController? {
    return self.window?.rootViewController as? MainViewController
  }
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    
    UIView.doBadSwizzleStuff()
    UIViewController.doBadSwizzleStuff()
    
    self.viewModel.inputs.applicationDidFinishLaunching(
      application: application,
      launchOptions: launchOptions
    )
    
    return self.viewModel.outputs.applicationDidFinishLaunchingReturnValue
  }
  
  func applicationWillEnterForeground(_: UIApplication) {
    self.viewModel.inputs.applicationWillEnterForeground()
  }
  
  func applicationDidEnterBackground(_: UIApplication) {
    self.viewModel.inputs.applicationDidEnterBackground()
  }
  
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
    return self.viewModel.inputs.applicationOpenUrl(
      application: app,
      url: url,
      options: options
    )
  }
  
  internal func applicationDidReceiveMemoryWarning(_: UIApplication) {
    self.viewModel.inputs.applicationDidReceiveMemoryWarning()
  }
}
