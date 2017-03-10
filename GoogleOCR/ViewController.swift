//
//  ViewController.swift
//  GoogleOCR
//
//  Created by Muna Tayeb on 6/10/1438 AH.
//  Copyright © 1438 Muna Tayeb. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var text: UILabel!
   
    @IBOutlet weak var imagev: UIImageView!
    var googleApiKey = "AIzaSyC0gA9lgcdKGKa95nSuOIzxgVn1aqpB4vg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagev.image = UIImage(named: "test")
        detectText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func  detectText () {
    // image is base64
       let image  = UIImage(named: "test")
    // target only PNG
    let imagedata = UIImagePNGRepresentation(image!)
    let  base64image = imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
   
        let request: Parameters = [
            "requests" :  [
                
                "image": [
                    
                    "content": base64image
                ] ,
                "features" : [
                    
                    "type": "TEXT_DETECTION",
                     "maxResults": 1
                ],
                "imageContext": [
                
                    "languageHints": ["ar"]
                
                ]
    ]
    ]

    // Include the value specified in the X-Ios-Bundle-Identifier in the request header when restricting the key in API Manager on Google Cloud Platform
      
        
        let httpHeader: HTTPHeaders = [
    "Content-Type" :  "application/json",
    "X-Ios-Bundle-Identifier" :  Bundle.main.bundleIdentifier ?? ""
    ]
      
    // Place the API key obtained by API Manager on Google Cloud Platform in googleApiKey 
        
        Alamofire.request("https://vision.googleapis.com/v1/images:annotate?key=\(googleApiKey)", method: .post , parameters: request, encoding: JSONEncoding.default ,headers: httpHeader).validate(statusCode: 200..<300).responseJSON {response in
           
            // processing the response
            print("--Request--: ",response.request)  // original URL request
            print("--Response--: ",response.response) // HTTP URL response
            print("--Data--: ",response.data)     // server data
            print("--Result--: ",response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
            self.googleResult (response :  response )
            
        }.responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
                print("Response Desc: \(response.result.description)")
                
                var statusCode = response.response?.statusCode
                if let error = response.result.error as? AFError {
                    statusCode = error._code // statusCode private
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                            statusCode = code
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        // statusCode = 3840 ???? maybe..
                    }
                    
                    print("Underlying error: \(error.underlyingError)")
                } else if let error = response.result.error as? URLError {
                    print("URLError occurred: \(error)")
                } else {
                    print("Unknown error: \(response.result.error)")
                }
        }
    }
func  googleResult (response :  DataResponse<Any> ) {
    guard  let  result  = response.result.value else {
    // End if the response is empty
     return
    }
    let  json  = JSON (result)
    let  annotations :  JSON  = json [ "responses" ] [ 0 ] [ "textAnnotations" ]
    var  detectedText :  String  =  ""
    
    // Extract the description from the result into a single string
    annotations.forEach { (_, annotation) in
        detectedText += annotation["description"].string!
        print("test: \(annotation["description"].string!)")
    
    }
    // display the result
    text.text = detectedText
        
    }
}

