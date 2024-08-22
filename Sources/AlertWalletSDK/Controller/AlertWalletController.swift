//
//  File.swift
//
//
//  Created by Reddy on 22/08/24.
//

import Foundation
import UIKit

public class AlertWalletController: UIViewController {

    public static let shared = AlertWalletController()

    public var delegate: AlertWalletControllerDelegate?

    private init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        print("SDK viewDidLoad");
    }


    public func checkEligibility(){
        print("SDK checkEligibility called didTapButton()");
        delegate?.didTapButton()

    }

    public func isWatchPairedToPhone() -> Bool {
        print("SDK isWatchPairedToPhone directly returning data from controller");
        return false;
    }

    public func startPassProvisioning(){
        print("SDK startPassProvisioning");
        let title = "GGGG"
        delegate?.didUpdateButtonTitle(to: title)

    }

    public func saveToWallet(parentViewController: UIViewController, thumbnail: String, displayName: String, description: String, saveLink: String){
        print("SDK saveToWallet");
        delegate?.didUpdateBackgroundColor(displayName: displayName)

    }

    public func syncPassToWatch(parentViewController: UIViewController, thumbnail: String, displayName: String, description: String, watchProvisioningBlob: String){
        print("SDK syncPassToWatch");

    }


}
