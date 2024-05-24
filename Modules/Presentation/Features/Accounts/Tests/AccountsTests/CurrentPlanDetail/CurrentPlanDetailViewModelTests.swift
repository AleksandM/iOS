@testable import Accounts
import AccountsMock
import XCTest

final class CurrentPlanDetailViewModelTests: XCTestCase {
    let features = [
        FeatureDetails(
            type: .storage,
            title: "Storage",
            freeText: "20GB",
            proText: "100GB"
        )
    ]

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func makeSUT(
        currentPlanName: String = "",
        currentPlanStorageUsed: String = "",
        features: [FeatureDetails]
    ) -> (
        viewModel: CurrentPlanDetailViewModel,
        router: MockCurrentPlanDetailRouter
    ) {
        let router = MockCurrentPlanDetailRouter()
        let viewModel = CurrentPlanDetailViewModel(
            currentPlanName: currentPlanName, 
            currentPlanStorageUsed: currentPlanStorageUsed,
            features: features,
            router: router
        )
        return (viewModel, router)
    }
    
    func testInit_shouldSetProperties() {
        let expectedName = "Pro Plan"
        let expectedStorage = "400 GB"
        let (sut, _) = makeSUT(
            currentPlanName: expectedName,
            currentPlanStorageUsed: expectedStorage,
            features: features
        )
        
        XCTAssertEqual(sut.currentPlanName, expectedName, "Expected currentPlanName to be '\(expectedName)'")
        XCTAssertEqual(sut.currentPlanStorageUsed, expectedStorage, "Expected currentPlanStorageUsed to be '\(expectedStorage)'")
        XCTAssertEqual(sut.features.count, features.count, "Expected features count to be \(features.count)")
        XCTAssertEqual(sut.features.first?.title, features.first?.title, "Expected first feature title to match")
    }
    
    func testDismiss_shouldCallRouterDismiss() {
        let (sut, router) = makeSUT(features: features)
        
        sut.dismiss()
        
        XCTAssertEqual(router.dismiss_calledTimes, 1, "Expected dismiss to be called on router")
    }
}
