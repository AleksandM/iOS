import DeviceCenter
import MEGADomain
import MEGAL10n
import MEGASDKRepo
import SwiftUI

extension MyAccountHallViewController {
    func navigateToDeviceCenter() {
        DeviceListViewRouter(
            navigationController: navigationController,
            deviceCenterBridge: makeDeviceCenterBridge(),
            deviceCenterUseCase:
                DeviceCenterUseCase(
                    deviceCenterRepository:
                        DeviceCenterRepository.newRepo
                ),
            nodeUseCase:
                NodeUseCase(
                    nodeDataRepository: NodeDataRepository.newRepo,
                    nodeValidationRepository: NodeValidationRepository.newRepo,
                    nodeRepository: NodeRepository.newRepo
                ),
            networkMonitorUseCase: NetworkMonitorUseCase(repo: NetworkMonitorRepository.newRepo),
            deviceCenterAssets: makeDeviceListAssetData()
        ).start()
    }
    
    func makeDeviceListAssetData() -> DeviceCenterAssets {
        DeviceCenterAssets(
            deviceListAssets:
                makeDeviceListAssets(),
            backupListAssets:
                makeBackupListAssets(),
            emptyStateAssets:
                makeEmptyStateAssets(),
            searchAssets:
                makeSearchAssets(),
            backupStatuses: backupStatusesList(),
            deviceCenterActions: deviceCenterActionList(),
            deviceIconNames: deviceIconNamesList()
        )
    }
    
    private func makeDeviceListAssets() -> DeviceListAssets {
        return DeviceListAssets(
            title: Strings.Localizable.Device.Center.title,
            currentDeviceTitle: Strings.Localizable.Device.Center.Current.Device.title,
            otherDevicesTitle: Strings.Localizable.Device.Center.Other.Devices.title,
            deviceDefaultName: Strings.Localizable.Device.Center.Default.Device.title
        )
    }
    
    private func makeBackupListAssets() -> BackupListAssets {
        return BackupListAssets(
            backupTypes: [
                BackupType(type: .backupUpload, iconName: Asset.Images.Backup.backupFolder.name),
                BackupType(type: .cameraUpload, iconName: Asset.Images.Backup.cameraUploadsFolder.name),
                BackupType(type: .mediaUpload, iconName: Asset.Images.Backup.cameraUploadsFolder.name),
                BackupType(type: .twoWay, iconName: Asset.Images.Backup.syncFolder.name),
                BackupType(type: .downSync, iconName: Asset.Images.Backup.syncFolder.name),
                BackupType(type: .upSync, iconName: Asset.Images.Backup.syncFolder.name),
                BackupType(type: .invalid, iconName: Asset.Images.Backup.syncFolder.name)
            ]
        )
    }
    
    private func makeEmptyStateAssets() -> EmptyStateAssets {
        return EmptyStateAssets(
            image: Asset.Images.EmptyStates.searchEmptyState.name,
            title: Strings.Localizable.noResults
        )
    }
    
    private func makeSearchAssets() -> SearchAssets {
        return SearchAssets(
            placeHolder: Strings.Localizable.search,
            cancelTitle: Strings.Localizable.cancel
        )
    }
    
    private func backupStatusesList() -> [BackupStatus] {
        return [
            BackupStatus(
                status: .upToDate,
                title: Strings.Localizable.Device.Center.Backup.UpToDate.Status.message,
                colorName: Colors.General.Green._34C759.name,
                iconName: Asset.Images.BackupStatus.upToDate.name
            ),
            BackupStatus(
                status: .scanning,
                title: Strings.Localizable.Device.Center.Backup.Scanning.Status.message,
                colorName: Colors.General.Blue._007Aff.name,
                iconName: Asset.Images.BackupStatus.updating.name
            ),
            BackupStatus(
                status: .initialising,
                title: Strings.Localizable.Device.Center.Backup.Initialising.Status.message,
                colorName: Colors.General.Blue._007Aff.name,
                iconName: Asset.Images.BackupStatus.updating.name
            ),
            BackupStatus(
                status: .updating,
                title: Strings.Localizable.Device.Center.Backup.Updating.Status.message,
                colorName: Colors.General.Blue._007Aff.name,
                iconName: Asset.Images.BackupStatus.updating.name
            ),
            BackupStatus(
                status: .noCameraUploads,
                title: Strings.Localizable.Device.Center.Backup.NoCameraUploads.Status.message,
                colorName: Colors.General.Orange.ff9500.name,
                iconName: Asset.Images.BackupStatus.noCameraUploads.name
            ),
            BackupStatus(
                status: .disabled,
                title: Strings.Localizable.Device.Center.Backup.Disabled.Status.message,
                colorName: Colors.General.Orange.ff9500.name,
                iconName: Asset.Images.BackupStatus.disabled.name
            ),
            BackupStatus(
                status: .offline,
                title: Strings.Localizable.Device.Center.Backup.Offline.Status.message,
                colorName: Colors.General.Gray._8E8E93.name,
                iconName: Asset.Images.BackupStatus.offlineStatus.name
            ),
            BackupStatus(
                status: .backupStopped,
                title: Strings.Localizable.Device.Center.Backup.BackupStopped.Status.message,
                colorName: Colors.General.Gray._8E8E93.name,
                iconName: Asset.Images.BackupStatus.error.name
            ),
            BackupStatus(
                status: .paused,
                title: Strings.Localizable.Device.Center.Backup.Paused.Status.message,
                colorName: Colors.General.Gray._8E8E93.name,
                iconName: Asset.Images.BackupStatus.paused.name
            ),
            BackupStatus(
                status: .outOfQuota,
                title: Strings.Localizable.Device.Center.Backup.OutOfQuota.Status.message,
                colorName: Colors.General.Red.ff3B30.name,
                iconName: Asset.Images.BackupStatus.outOfQuota.name
            ),
            BackupStatus(
                status: .error,
                title: Strings.Localizable.Device.Center.Backup.Error.Status.message,
                colorName: Colors.General.Red.ff3B30.name,
                iconName: Asset.Images.BackupStatus.error.name
            ),
            BackupStatus(
                status: .blocked,
                title: Strings.Localizable.Device.Center.Backup.Blocked.Status.message,
                colorName: Colors.General.Red.ff3B30.name,
                iconName: Asset.Images.BackupStatus.disabled.name
            )
        ]
    }
    
    private func deviceCenterActionList() -> [DeviceCenterAction] {
        return [
            DeviceCenterAction(
                type: .cameraUploads,
                title: Strings.Localizable.cameraUploadsLabel,
                dynamicSubtitle: {
                    CameraUploadManager.isCameraUploadEnabled ? Strings.Localizable.Device.Center.Camera.Uploads.Action.Status.enabled :
                        Strings.Localizable.Device.Center.Camera.Uploads.Action.Status.disabled
                },
                icon: Asset.Images.Settings.cameraUploadsSettings.name
            ),
            DeviceCenterAction(
                type: .info,
                title: Strings.Localizable.info,
                icon: Asset.Images.Generic.info.name
            ),
            DeviceCenterAction(
                type: .rename,
                title: Strings.Localizable.rename,
                icon: Asset.Images.Generic.rename.name
            ),
            DeviceCenterAction(
                type: .showInCloudDrive,
                title: Strings.Localizable.Device.Center.Show.In.Cloud.Drive.Action.title,
                icon: Asset.Images.ActionSheetIcons.cloudDriveFolder.name
            ),
            DeviceCenterAction(
                type: .showInBackups,
                title: Strings.Localizable.Device.Center.Show.In.Backups.Action.title,
                icon: Asset.Images.MyAccount.backups.name
            ),
            DeviceCenterAction(
                type: .sort,
                title: Strings.Localizable.sortTitle,
                icon: Asset.Images.ActionSheetIcons.sort.name,
                subActions: [
                    DeviceCenterAction(
                        type: .sortAscending,
                        title: Strings.Localizable.nameAscending,
                        icon: Asset.Images.ActionSheetIcons.SortBy.ascending.name
                    ),
                    DeviceCenterAction(
                        type: .sortDescending,
                        title: Strings.Localizable.nameDescending,
                        icon: Asset.Images.ActionSheetIcons.SortBy.descending.name
                    )
                ]
            )
        ]
    }
    
    private func deviceIconNamesList() -> [BackupDeviceTypeEntity: String] {
        [
            .android: Asset.Images.Backup.android.name,
            .iphone: Asset.Images.Backup.ios.name,
            .linux: Asset.Images.Backup.pcLinux.name,
            .mac: Asset.Images.Backup.pcMac.name,
            .win: Asset.Images.Backup.pcWindows.name,
            .defaultMobile: Asset.Images.Backup.mobile.name,
            .defaultPc: Asset.Images.Backup.pc.name
        ]
    }
    
    private func makeDeviceCenterBridge() -> DeviceCenterBridge {
        let bridge = DeviceCenterBridge()
        
        bridge.cameraUploadActionTapped = { [weak self] cameraUploadStatusChanged in
            guard let navigationController = self?.findTopNavigationController() else { return }
    
            CameraUploadsSettingsViewRouter(presenter: navigationController, closure: {
                cameraUploadStatusChanged()
            }).start()
        }

        bridge.infoActionTapped = { [weak self] nodeEntity in
            self?.showNodeInfo(for: nodeEntity)
        }
        
        bridge.renameActionTapped = { renameEntity in
            guard let presenter = UIApplication.mainTabBarRootViewController() else { return }
            RenameRouter(
                presenter: presenter,
                type: .device(
                    renameEntity: renameEntity
                ),
                renameUseCase:
                    RenameUseCase(
                        renameRepository: RenameRepository.newRepo
                    )
            ).start()
        }
        
        bridge.showInCloudDriveActionTapped = { [weak self] nodeEntity in
            Task {
                await self?.showInCloudDrive(nodeEntity)
            }
        }
        
        bridge.showInBackupsActionTapped = { [weak self] nodeEntity in
            Task {
                await self?.showContentForNode(nodeEntity, inBackupSection: true)
            }
        }
        
        bridge.sortActionTapped = { _, _ in
            // Will be added in future tickets
        }
        
        return bridge
    }
    
    private func showNodeInfo(for node: NodeEntity?) {
        guard let node = node?.toMEGANode(in: MEGASdk.shared),
              let presenter = findTopNavigationController() else { return }
        
        let nodeInfoViewModel = NodeInfoViewModel(
            withNode: node,
            shareUseCase: ShareUseCase(repo: ShareRepository.newRepo),
            shouldDisplayContactVerificationInfo: MEGASdk.shared.isContactVerificationWarningEnabled
        )
        
        let nodeInfoNavigation = NodeInfoViewController.instantiate(withViewModel: nodeInfoViewModel, delegate: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            presenter.present(nodeInfoNavigation, animated: true, completion: nil)
        }
    }
    
    private func showInCloudDrive(_ nodeEntity: NodeEntity) async {
        guard let mainTBC = UIApplication.mainTabBarRootViewController() else { return }
        mainTBC.selectedIndex = TabType.cloudDrive.rawValue
        
        guard let navigationController = findTopNavigationController() else { return }
        navigationController.popToRootViewController(animated: false)
        
        await showContentForNode(nodeEntity, inBackupSection: false)
    }

    private func showContentForNode(_ nodeEntity: NodeEntity?, inBackupSection isBackup: Bool) async {
        guard let nodeEntity,
              let navigationController = findTopNavigationController() else { return }
        
        let nodesTree = await fetchNodesTree(for: nodeEntity, isBackup: isBackup)
        let viewControllersToAdd = nodesTree?.compactMap { createCloudDriveVCForNode($0, isBackup: isBackup) } ?? []
        
        let updatedStack = updateViewControllerStack(navigationController.viewControllers, appending: viewControllersToAdd, isBackup: isBackup)
        navigationController.setViewControllers(updatedStack, animated: false)
    }
    
    private func findTopNavigationController() -> UINavigationController? {
        guard let tabBarController = UIApplication.mainTabBarRootViewController(),
              let selectedNavController = tabBarController.selectedViewController as? UINavigationController else {
            return nil
        }
        
        return selectedNavController
    }
    
    private func fetchNodesTree(for nodeEntity: NodeEntity, isBackup: Bool) async -> [NodeEntity]? {
        if isBackup {
            let backupsUseCase = BackupsUseCase(
                backupsRepository: BackupsRepository.newRepo,
                nodeRepository: NodeRepository.newRepo
            )
            return await backupsUseCase.parentsForBackupHandle(nodeEntity.handle)
        } else {
            let nodeUseCase = NodeUseCase(
                nodeDataRepository: NodeDataRepository.newRepo,
                nodeValidationRepository: NodeValidationRepository.newRepo,
                nodeRepository: NodeRepository.newRepo
            )
            return await nodeUseCase.parentsForHandle(nodeEntity.handle)
        }
    }

    func updateViewControllerStack(_ currentStack: [UIViewController], appending viewControllersToAdd: [UIViewController], isBackup: Bool) -> [UIViewController] {
        let updatedStack: [UIViewController]
        
        if isBackup {
            let filteredStack = currentStack.prefix { !($0 is MyAccountHallViewController) }
            
            if let targetVC = currentStack.first(where: { $0 is MyAccountHallViewController }) {
                updatedStack = Array(filteredStack) + [targetVC] + viewControllersToAdd
            } else {
                updatedStack = Array(filteredStack) + viewControllersToAdd
            }
        } else {
            updatedStack = currentStack + viewControllersToAdd
        }
        
        return updatedStack
    }
    
    private func createCloudDriveVCForNode(_ node: NodeEntity, isBackup: Bool) -> CloudDriveViewController? {
        guard let node = node.toMEGANode(in: MEGASdk.shared),
              let cloudDriveVC = UIStoryboard(name: "Cloud", bundle: nil).instantiateViewController(withIdentifier: "CloudDriveID") as? CloudDriveViewController else { return nil }
        
        cloudDriveVC.parentNode = node
        cloudDriveVC.displayMode = isBackup ? .backup : .cloudDrive
        return cloudDriveVC
    }
}
