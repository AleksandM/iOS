import Accounts
import SwiftUI

public class MockCurrentPlanDetailRouter: CurrentPlanDetailRouting {
    public var dismiss_calledTimes = 0
    
    public init() {}
    
    public func build() -> UIViewController {
        UIViewController()
    }
    public func start() {}
    
    public func dismiss() {
        dismiss_calledTimes += 1
    }
}
