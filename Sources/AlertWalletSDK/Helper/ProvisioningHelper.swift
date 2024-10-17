//
//  ProvisioningHelper.swift
//
//
//  Created by Reddy on 23/08/24.
//

import Foundation
import PassKit
import os
import UIKit

class ProvisioningHelper: NSObject,PKAddSecureElementPassViewControllerDelegate{

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ProvisioningHelper.self)
    )

    static let shared = ProvisioningHelper()
    public weak var delegate: AlertWalletControllerDelegate?
    public var isDismissed: Bool = false
    public func initiateWalletProvisioning(with provisioningResponse: ProvisioningCredential , viewController: UIViewController , delegate: AlertWalletControllerDelegate?, previewImage: UIImage){
        Self.logger.info("ProvisioningHelper initiateWalletProvisioning Begin")
        let provisioningInfo = provisioningResponse.provisioningInformation
        let provisioningCredentialIdentifier = provisioningInfo.provisioningCredentialIdentifier
        let cardTemplateIdentifier = provisioningInfo.cardTemplateIdentifier
        let sharingInstanceIdentifier = provisioningInfo.sharingInstanceIdentifier
        let environmentIdentifier = PropertiesManager.shared.getEnvironmentIdentifier() ?? provisioningInfo.envIdentifier
        let ownerDisplayName = PropertiesManager.shared.getOwnerName() ?? "Johnny"
        let localizedDescription = PropertiesManager.shared.getPassDescription() ?? "Pass"
        self.delegate = delegate
        self.isDismissed = false
        let appleUITimeout = PropertiesManager.shared.getAppleWalletUITimeout()

        let preview = PKShareablePassMetadata.Preview(
            passThumbnail: previewImage.cgImage!,
            localizedDescription: localizedDescription)

        preview.ownerDisplayName = ownerDisplayName

        let passMetadata = PKShareablePassMetadata(
            provisioningCredentialIdentifier: provisioningCredentialIdentifier,
            sharingInstanceIdentifier: sharingInstanceIdentifier,
            cardTemplateIdentifier: cardTemplateIdentifier,
            preview: preview)

        if let envId = environmentIdentifier {
            passMetadata.serverEnvironmentIdentifier = envId;
        }

        if let accountHash = provisioningInfo.accountHash, let relyingPartyIdentifier = provisioningInfo.relyingPartyIdentifier {
            passMetadata.accountHash = accountHash
            passMetadata.relyingPartyIdentifier = relyingPartyIdentifier
        }

        PKAddShareablePassConfiguration.forPassMetadata([passMetadata], action: .add) { sePassConfig, err in
            guard let config = sePassConfig else {
                Self.logger.debug("ProvisioningHelper intiateWalletProvisioning:: error creating pass config - \(String(describing: err))")
                return
            }
            guard let vc = self.createSEViewController(for: config) else { return }
            if(appleUITimeout > 0){
                let timeout : TimeInterval = TimeInterval(appleUITimeout)
                DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                    if(!self.isDismissed){
                        self.isDismissed = true;
                        if(vc.isViewLoaded){
                            vc.dismiss(animated: true,completion: nil)
                            delegate?.AlertWalletUIViewController(AlertWalletController.shared, onWalletProvisioningError: WalletProvisioningResponse(message: "TIMEOUT , as per configuration it is  \(appleUITimeout) seconds")   )
                        }
                    }
                }
            }
            viewController.present(vc, animated: true)
        }
    }

    private func createSEViewController(for passConfig: PKAddShareablePassConfiguration) -> PKAddSecureElementPassViewController? {
        let canAddSePass = PassManager().canAddSePass(for: passConfig)
        guard canAddSePass else {
            Self.logger.error("ProvisioningHelper intiateWalletProvisioning:: Unable to add an SE Pass with specified configuration")
            return nil
        }
        guard let vc = PKAddSecureElementPassViewController(configuration: passConfig, delegate: self) else {
            Self.logger.error("ProvisioningHelper intiateWalletProvisioning:: Unable to create an SE Pass VC with specified configuration")
            return nil
        }
        return vc
    }

    func addSecureElementPassViewController(_ controller: PKAddSecureElementPassViewController, didFinishAddingSecureElementPasses passes: [PKSecureElementPass]?, error: (any Error)?) {
        if let error = error as? PKAddSecureElementPassError {
            delegate?.AlertWalletUIViewController(AlertWalletController.shared, onWalletProvisioningError: WalletProvisioningResponse(message: error.localizedDescription)   )
        }
        if (passes != nil ) {
            delegate?.AlertWalletUIViewController(AlertWalletController.shared, onWalletProvisioningSuccess: WalletProvisioningResponse(
                success: true,
                passUrl: passes?.first?.passURL,
                message: "Pass Added Successfully",
                pass: PassInformation(passType: passes?.first?.passType.hashValue ,passTypeIdentifier: passes?.first?.passTypeIdentifier , webServiceURL: passes?.first?.webServiceURL)))
        }
        if(!self.isDismissed){
            self.isDismissed = true;
            controller.dismiss(animated: true)
        }
    }


    public func validateWalletProvisioning(with provisioningResponse: ProvisioningCredential , viewController: UIViewController , delegate: AlertWalletControllerDelegate?, previewImage: UIImage){
        Self.logger.info("ProvisioningHelper ProvisioningHelper validateWalletProvisioning Begin")
        let provisioningInfo = provisioningResponse.provisioningInformation
        let provisioningCredentialIdentifier = provisioningInfo.provisioningCredentialIdentifier
        let cardTemplateIdentifier = provisioningInfo.cardTemplateIdentifier
        let sharingInstanceIdentifier = provisioningInfo.sharingInstanceIdentifier
        let environmentIdentifier = PropertiesManager.shared.getEnvironmentIdentifier() ?? provisioningInfo.envIdentifier
        let ownerDisplayName = PropertiesManager.shared.getOwnerName() ?? "Johnny"
        let localizedDescription = PropertiesManager.shared.getPassDescription() ?? "Pass"
        self.delegate = delegate

        let preview = PKShareablePassMetadata.Preview(
            passThumbnail: previewImage.cgImage!,
            localizedDescription: localizedDescription)

        preview.ownerDisplayName = ownerDisplayName

        let passMetadata = PKShareablePassMetadata(
            provisioningCredentialIdentifier: provisioningCredentialIdentifier,
            sharingInstanceIdentifier: sharingInstanceIdentifier,
            cardTemplateIdentifier: cardTemplateIdentifier,
            preview: preview)

        if let envId = environmentIdentifier {
            passMetadata.serverEnvironmentIdentifier = envId;
        }

        if let accountHash = provisioningInfo.accountHash, let relyingPartyIdentifier = provisioningInfo.relyingPartyIdentifier {
            passMetadata.accountHash = accountHash
            passMetadata.relyingPartyIdentifier = relyingPartyIdentifier
        }

        PKAddShareablePassConfiguration.forPassMetadata([passMetadata], action: .add) { sePassConfig, err in
            guard let config = sePassConfig else {
                Self.logger.error("ProvisioningHelper validateWalletProvisioning:: error creating pass config - \(String(describing: err))")
                return
            }
            let canAddSePass = PassManager().canAddSePass(for: config)
            if (canAddSePass){
                delegate?.AlertWalletUIViewController(AlertWalletController.shared, onPassAddValidation: true)
            } else{
                delegate?.AlertWalletUIViewController(AlertWalletController.shared, onPassAddValidation: false)
            }
        }
    }

}

