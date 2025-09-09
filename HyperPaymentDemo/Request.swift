import UIKit
import OPPWAMobile_MSA

//TODO: This class uses our test integration server (OPPWAMobile_MSA.xcframework); please adapt it to use your own backend API.
class Request: NSObject {
    
    static func requestCheckoutID(amount: Double,
                                  currency: String,
                                  testMode: String = "INTERNAL",
                                  completion: @escaping (String?) -> Void) {
        let extraParamaters: [String:String] = [
            "testMode": testMode,
            "sendRegistration": "false"
        ]
        
        OPPMerchantServer.requestCheckoutId(amount: amount,
                                            currency: currency,
                                            paymentType: Config.paymentType,
                                            serverMode: .test,
                                            extraParameters: extraParamaters) { checkoutId, error in
//            completion("967494B5F71EC8704069B9BB9A222309.uat01-vm-tx01")
            if let checkoutId = checkoutId {
                completion(checkoutId)
            } else {
                completion(nil)
            }
        }
    }
    
    static func requestCheckoutID(amount: Double, currency: String, extraParamaters: [String:String], completion: @escaping (String?) -> Void) {
        OPPMerchantServer.requestCheckoutId(amount: amount,
                                            currency: currency,
                                            paymentType: CopyandPayConfig.paymentType,
                                            serverMode: .test,
                                            extraParameters: extraParamaters) { checkoutId, error in
            if let checkoutId = checkoutId {
                completion(checkoutId)
            } else {
                completion(nil)
            }
        }
    }
    
    static func requestPaymentStatus(resourcePath: String, completion: @escaping (OPPPaymentStatusResponse?, Error?) -> Void) {
        OPPMerchantServer.requestPaymentStatus(resourcePath: resourcePath) { paymentStatusResponse, error in
            completion(paymentStatusResponse, error)
        }
    }
}
