import Foundation

protocol NodeLabelActionRepositoryProtocol {

    var labelColors: [NodeLabelColor] { get }

    func setNodeLabelColor(
        _ labelColor: NodeLabelColor,
        forNode nodeHandle: MEGAHandle,
        completion: ((Result<Void, NodeLabelActionDomainError>) -> Void)?
    )

    func resetNodeLabelColor(
        forNode nodeHandle: MEGAHandle,
        completion: ((Result<Void, NodeLabelActionDomainError>) -> Void)?
    )

    func nodeLabelColor(
        forNode nodeHandle: MEGAHandle,
        completion: ((Result<NodeLabelColor, NodeLabelActionDomainError>) -> Void)?
    )
}

final class NodeLabelActionRepository: NodeLabelActionRepositoryProtocol {

    private let sdk: MEGASdk

    init(sdk: MEGASdk = MEGASdkManager.sharedMEGASdk()) {
        self.sdk = sdk
    }

    func setNodeLabelColor(
        _ labelColor: NodeLabelColor,
        forNode nodeHandle: MEGAHandle,
        completion: ((Result<Void, NodeLabelActionDomainError>) -> Void)?
    ) {
        guard let node = sdk.node(forHandle: nodeHandle) else {
            completion?(.failure(.nodeNotFound))
            return
        }

        guard let SDKLabelColor = MEGANodeLabel(rawValue: labelColor.rawValue) else {
            completion?(.failure(.unsupportedNodeLabelColorFound))
            return
        }

        let delegate = MEGAGenericRequestDelegate { (request, error) in
            if let sdkError = error.sdkError {
                completion?(.failure(.sdkError(sdkError)))
                return
            }
            completion?(.success(()))
        }

        sdk.setNodeLabel(node, label: SDKLabelColor, delegate: delegate)
    }

    func resetNodeLabelColor(
        forNode nodeHandle: MEGAHandle,
        completion: ((Result<Void, NodeLabelActionDomainError>) -> Void)?
    ) {
        guard let node = sdk.node(forHandle: nodeHandle) else {
            completion?(.failure(.nodeNotFound))
            return
        }
        let delegate = MEGAGenericRequestDelegate { (request, error) in
            if let sdkError = error.sdkError {
                completion?(.failure(.sdkError(sdkError)))
                return
            }
            completion?(.success(()))
        }
        sdk.resetNodeLabel(node, delegate: delegate)
    }

    var labelColors: [NodeLabelColor] {
        NodeLabelColor.allCases
    }

    func nodeLabelColor(
        forNode nodeHandle: MEGAHandle,
        completion: ((Result<NodeLabelColor, NodeLabelActionDomainError>) -> Void)?
    ) {
        guard let node = sdk.node(forHandle: nodeHandle) else {
            completion?(.failure(.nodeNotFound))
            return
        }
        guard let labelColor = NodeLabelColor(rawValue: node.label.rawValue) else {
            completion?(.failure(.unsupportedNodeLabelColorFound))
            return
        }
        completion?(.success(labelColor))
    }
}

enum NodeLabelColor: Int, CaseIterable {
    case unknown = 0
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case grey
}

private extension NodeLabelColor {
    var sdkLabel: MEGANodeLabel {
        return MEGANodeLabel(rawValue: rawValue) ?? .unknown
    }
}
