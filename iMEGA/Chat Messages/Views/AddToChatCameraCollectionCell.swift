
import UIKit

class AddToChatCameraCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var liveFeedView: UIView!
    @IBOutlet weak var cameraIconImageView: UIImageView!

    var previewLayer: AVCaptureVideoPreviewLayer!
    var isCurrentShowingLiveFeed = false
    
    enum LiveFeedError: Error {
        case askForPermission
        case captureDeviceInstantiationFailed
        case captureDeviceInputInstantiationFailed
    }
    
    let permissionHandler = DevicePermissionsHandler()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateAppearance()
    }
    
    func prepareToShowLivefeed() {
        guard permissionHandler.isVideoPermissionAuthorized else {
            return
        }
        
        liveFeedView.isHidden = false
    }
    
    func showLiveFeed() throws {
        if permissionHandler.shouldAskForVideoPermissions {
            updateCameraIconImageView()
            throw LiveFeedError.askForPermission
        }
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        liveFeedView.isHidden = false
        animateFading()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        liveFeedView.layer.addSublayer(previewLayer)
        previewLayer.frame = liveFeedView.layer.bounds

        let deviceDiscoverySession = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                             for: AVMediaType.video,
                                                             position: .back)
        
        guard let captureDevice = deviceDiscoverySession else {
            throw LiveFeedError.captureDeviceInstantiationFailed
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            throw LiveFeedError.captureDeviceInputInstantiationFailed
        }
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        isCurrentShowingLiveFeed = true
        updateCameraIconImageView()
    }
    
    func hideLiveFeedView() {
        liveFeedView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addCornerRadius()
        guard let previewLayer = previewLayer else {
            return
        }
        
        previewLayer.frame = liveFeedView.layer.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }
    
    private func animateFading() {
        guard let mainView = liveFeedView.superview else {
            return
        }
        
        let lifeFeedFadingView = UIView()
        lifeFeedFadingView.backgroundColor = .black
        mainView.insertSubview(lifeFeedFadingView, aboveSubview: liveFeedView)
        lifeFeedFadingView.autoPinEdgesToSuperviewEdges()
        
        UIView.animate(withDuration: 0.2, animations: {
            lifeFeedFadingView.alpha = 0.0
        }, completion: { _ in
            lifeFeedFadingView.removeFromSuperview()
        })

    }
    
    private func addCornerRadius() {
        layer.cornerRadius = 4.0
        
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft],
                                    cornerRadii: CGSize(width: 8.0, height: 0.0))

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    private func updateCameraIconImageView() {
        cameraIconImageView.image = (traitCollection.userInterfaceStyle == .dark) ? #imageLiteral(resourceName: "cameraIconWhite") : (permissionHandler.isVideoPermissionAuthorized ? Asset.Images.Chat.cameraIconWhite.image : Asset.Images.Chat.cameraIcon.image)
    }
    
    private func updateAppearance() {
        backgroundColor = .mnz_inputbarButtonBackground(traitCollection)
        updateCameraIconImageView()
    }
}
