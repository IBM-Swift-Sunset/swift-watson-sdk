/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import RestKit
import KituraNet
import SwiftyJSON

import Foundation

/**
 The Watson Personality Insights service uses linguistic analytics to extract a spectrum
 of cognitive and social characteristics from the text data that a person generates
 through blogs, tweets, forum posts, and more.
 */
public class PersonalityInsights {
    
    private let username: String
    private let password: String
    private let serviceURL: String
    private let domain = "com.ibm.watson.developer-cloud.PersonalityInsightsV2"

    /**
     Create a `PersonalityInsights` object.
     
     - parameter username: The username used to authenticate with the service.
     - parameter password: The password used to authenticate with the service.
     - parameter serviceURL: The base URL to use when contacting the service.
     */
    public init(
        username: String,
        password: String,
        serviceURL: String = "https://gateway.watsonplatform.net/personality-insights/api")
    {
        self.username = username
        self.password = password
        self.serviceURL = serviceURL
    }

    /**
     Analyze text to generate a personality profile.
 
     - parameter text: The text to analyze.
     - parameter acceptLanguage: The desired language of the response.
     - parameter contentLanguage: The language of the text being analyzed.
     - parameter includeRaw: If true, then a raw score for each characteristic is returned in
        addition to a normalized score. Raw scores are not compared with a sample population.
        A raw sampling error for each characteristic is also returned.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the personality profile.
     */
    public func getProfile(
        text text: String,
        acceptLanguage: String? = nil,
        contentLanguage: String? = nil,
        includeRaw: Bool? = nil,
        failure: (RestError -> Void)? = nil,
        success: Profile -> Void)
    {
        guard let content = text.data(using: NSUTF8StringEncoding) else {
            let failureReason = "Text could not be encoded to NSData with NSUTF8StringEncoding."
            let error = RestError.badData(failureReason)
            failure?(error)
            return
        }

        getProfile(
            content: content,
            contentType: "text/plain",
            acceptLanguage: acceptLanguage,
            contentLanguage: contentLanguage,
            includeRaw: includeRaw,
            failure: failure,
            success: success
        )
    }

    /**
     Analyze the text of a webpage to generate a personality profile.
     The HTML tags are stripped before the text is analyzed.

     - parameter html: The webpage that contains text to analyze.
     - parameter acceptLanguage: The desired language of the response.
     - parameter contentLanguage: The language of the text being analyzed.
     - parameter includeRaw: If true, then a raw score for each characteristic is returned in
        addition to a normalized score. Raw scores are not compared with a sample population.
        A raw sampling error for each characteristic is also returned.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the personality profile.
     */
    public func getProfile(
        html html: String,
        acceptLanguage: String? = nil,
        contentLanguage: String? = nil,
        includeRaw: Bool? = nil,
        failure: (RestError -> Void)? = nil,
        success: Profile -> Void)
    {
        guard let content = html.data(using: NSUTF8StringEncoding) else {
            let failureReason = "HTML could not be encoded to NSData with NSUTF8StringEncoding."
            let error = RestError.badData(failureReason)
            failure?(error)
            return
        }

        getProfile(
            content: content,
            contentType: "text/html",
            acceptLanguage: acceptLanguage,
            contentLanguage: contentLanguage,
            includeRaw: includeRaw,
            failure: failure,
            success: success
        )
    }

    /**
     Analyze input content items to generate a personality profile.
 
     - parameter contentItems: The content items to analyze.
     - parameter includeRaw: If true, then a raw score for each characteristic is returned in
        addition to a normalized score. Raw scores are not compared with a sample population.
        A raw sampling error for each characteristic is also returned.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the personality profile.
     */
    public func getProfile(
        contentItems contentItems: [ContentItem],
        acceptLanguage: String? = nil,
        contentLanguage: String? = nil,
        includeRaw: Bool? = nil,
        failure: (RestError -> Void)? = nil,
        success: Profile -> Void)
    {
        var aggregateItems = ""
        for count in 0...contentItems.count-1 {
            aggregateItems += contentItems[count].toJSON().rawString()!
            if(count != contentItems.count-1) {
                aggregateItems += ","
            }
        }
        
        var completeItems = "{\"contentItems\": [\(aggregateItems)]}"
    //    completeItems = completeItems.replacingOccurrences(of: "\n", with: "")
    //    completeItems = completeItems.replacingOccurrences(of: "\\", with: "")
 
        guard let content = completeItems.data(using: NSUTF8StringEncoding) else {
            let failureReason = "Content items could not be serialized to JSON."
            let error = RestError.badData(failureReason)
            failure?(error)
            return
        }

        getProfile(
            content: content,
            contentType: "application/json",
            acceptLanguage: acceptLanguage,
            contentLanguage: contentLanguage,
            includeRaw: includeRaw,
            failure: failure,
            success: success
        )
    }


    /**
     Analyze content to generate a personality profile.
 
     - parameter content: The content to analyze.
     - parameter contentType: The MIME content-type of the content.
     - parameter acceptLanguage: The desired language of the response.
     - parameter contentLanguage: The language of the text being analyzed.
     - parameter includeRaw: If true, then a raw score for each characteristic is returned in
        addition to a normalized score. Raw scores are not compared with a sample population.
        A raw sampling error for each characteristic is also returned.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the personality profile.
     */
    private func getProfile(
        content: NSData?,
        contentType: String,
        acceptLanguage: String? = nil,
        contentLanguage: String? = nil,
        includeRaw: Bool? = nil,
        failure: (RestError -> Void)? = nil,
        success: Profile -> Void)
    {
        // construct query parameters
        var queryParameters = [NSURLQueryItem]()
        if let includeRaw = includeRaw {
            let queryParameter = NSURLQueryItem(name: "include_raw", value: "\(includeRaw)")
            queryParameters.append(queryParameter)
        }

        // construct header parameters
        var headerParameters = [String: String]()
        if let acceptLanguage = acceptLanguage {
            headerParameters["Accept-Language"] = acceptLanguage
        }
        if let contentLanguage = contentLanguage {
            headerParameters["Content-Language"] = contentLanguage
        }

        // construct REST request
        let request = RestRequest(
            method: .POST,
            url: serviceURL + "/v2/profile",
            acceptType: "application/json",
            contentType: contentType,
            queryParameters: queryParameters,
            username: self.username,
            password: self.password,
            headerParameters: headerParameters,
            messageBody: content
        )

        // execute REST request
        request.responseJSON { response in
            switch response {
            case .success(let json): success(Profile(json: json))
            case .failure(let error): failure?(error)
            }
        }
    }
}
