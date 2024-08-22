//
//  File.swift
//
//
//  Created by Reddy on 22/08/24.
//

import WatchConnectivity
final class AppleWatchDetector: NSObject , WCSessionDelegate {

    public static let shared = AppleWatchDetector()
    public weak var delegate: AlertWalletControllerDelegate?
    private var session : WCSession? = nil

    private override init() {
        super.init()
        print("I am from init");
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }else{
            self.session = nil
        }
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        self.session = session
        print("I am session");
        let isPaired  = self.session!.isPaired
        print("I am session - delegate \(isPaired)");
        delegate?.isWatchPaired(AlertWalletController.shared, isWatchPaired: isPaired)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    public func checkIfWatchIsPaired() {
        if(self.session != nil){
            let isPaired = self.session!.isPaired
            delegate?.isWatchPaired(AlertWalletController.shared, isWatchPaired: isPaired)
        }else if(self.session == nil){
            if WCSession.isSupported() {
                let isPaired = WCSession.default.isPaired
                delegate?.isWatchPaired(AlertWalletController.shared, isWatchPaired: isPaired)
            }
        }else{
            print("I am   null");
            delegate?.isWatchPaired(AlertWalletController.shared, isWatchPaired: false)
        }
    }
    public func initialize() {
        print("dummy check");
    }

}

