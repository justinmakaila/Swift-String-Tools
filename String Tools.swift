//
//  String Tools.swift
//  Swift String Tools
//
//  Created by Jamal Kharrat on 8/11/14.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

extension String{
    
    //MARK: helper methods
    
    /**
    Returns the length of the string.
    
    :returns: Int length of the string.
    */

    var length: Int {
        return countElements(self)
    }
    
    var objcLength: Int {
        return self.utf16Count
    }
    /**
    perform substringWithRange using NSRange, without switching the String to an Obj-C NSString
    
    Source: https://github.com/sketchytech/substringWithNSRange
    
    :param: range: NSRange
    :returns: Returns a string object containing the characters of the `String` that lie within a given range (NSRange).
    
    */
    func substringWithNSRange(range:NSRange)-> String {
        let begin = advance(self.startIndex, range.location),
        finish = advance(self.endIndex, range.location+range.length-self.utf16Count)
        return self.substringWithRange(Range(start:begin, end:finish))
    }
    
    
    
    
    //MARK: - Linguistics
    
    /**
    Returns the langauge of a String
    
    NOTE: String has to be at least 4 characters, otherwise the method will return nil.
    
    :returns: String! Returns a string representing the langague of the string (e.g. en, fr, or und for undefined).
    */
    func detectLanguage() -> String! {
        if self.length > 4 {
            var token : dispatch_once_t = 0
            var tagger : NSLinguisticTagger?
            dispatch_once(&token) {
                tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagSchemeLanguage], options: 0)
            }
            tagger?.string = self
            return tagger?.tagAtIndex(0, scheme: NSLinguisticTagSchemeLanguage, tokenRange: nil, sentenceRange: nil)
        }
            return nil
    }
    
    /**
    Check the text direction of a given String.
    
    NOTE: String has to be at least 4 characters, otherwise the method will return false.
    
    :returns: Bool The Bool will return true if the string was writting in a right to left langague (e.g. Arabic, Hebrew)
    
    */
    func isRightToLeft() -> Bool {
        let language = self.detectLanguage()
        return (language? == "ar" || language? == "he")
    }
    
    
    
    
    //MARK: - Usablity & Social
    /**
    Check that a String is only made of white spaces, and new line characters.
    
    :returns: Bool
    */
    func isOnlyEmptySpacesAndNewLineCharacters() -> Bool {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).length == 0
    }
    
    
    
    /**
    Check that a String is 'tweetable' can be used in a tweet.
    
    :returns: Bool
    */
    func isTweetable() -> Bool {
        let tweetLength = 140
        let linksLength = self.getLinks().count * 23
        let remaining = tweetLength - linksLength
        if linksLength != 0 {
            return remaining < 0
        } else {
            return !(self.utf16Count > tweetLength || self.utf16Count == 0 || self.isOnlyEmptySpacesAndNewLineCharacters())
        }
    }
    
    /**
    Gets an array of Strings for all links found in a String
    
    :returns: [String!]
    */
    func getLinks() -> [String] {
        let error : NSErrorPointer = NSErrorPointer()
        let detector  : NSDataDetector = NSDataDetector(types: NSTextCheckingType.Link.toRaw(), error: error)
        let links = detector.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, self.utf16Count)) as [NSTextCheckingResult]
        let someUrlStrings = links.map() {
            (t : NSTextCheckingResult) -> String! in
                return t.URL.absoluteString
        }

        var urlStrings:[String] = []
        for urlString in someUrlStrings {
            if let u = urlString {
                urlStrings.append(u)
            }
        }
        return urlStrings
    }
    
    /**
    Gets an array of URLs for all links found in a String
    
    :returns: [NSURL]
    */
    func getURLs() -> [NSURL] {
        let error : NSErrorPointer = NSErrorPointer()
        let detector  : NSDataDetector = NSDataDetector(types: NSTextCheckingType.Link.toRaw(), error: error)
        let links = detector.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, self.utf16Count)) as [NSTextCheckingResult]
        let someUrls:[NSURL!] = links.map() {
            (t : NSTextCheckingResult) -> NSURL! in /*I'm using mapping beacuase it's cool! 😎*/
            return t.URL
        }
        
        var urls:[NSURL] = []
        for url in someUrls {
            if let u = url {
                urls.append(u)
            }
        }
        return urls
    }
    
    
    /**
    Gets an array of dates for all dates found in a String
    
    :returns: [NSDate]
    */
    func getDates() -> [NSDate] {
        let error : NSErrorPointer = NSErrorPointer()
        let detector  : NSDataDetector = NSDataDetector(types: NSTextCheckingType.Date.toRaw(), error: error)
        let links = detector.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, self.utf16Count)) as [NSTextCheckingResult]
        let someDates = links.map(){
            (t : NSTextCheckingResult) -> NSDate! in
            return t.date
        }
        var dates:[NSDate] = []
        for date in someDates {
            if let d = date {
                dates.append(d)
            }
        }
        return dates
    }
    
    /**
    Gets an array of strings (hashtags #acme) for all links found in a String
    
    :returns: [String]
    */
    func getHashtags() -> [String] {
        let hashtagDetector = NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        let results = hashtagDetector.matchesInString(self, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, self.utf16Count)) as [NSTextCheckingResult]
        let someHashtags = results.map(){
            (t : NSTextCheckingResult) -> String! in
                let range :NSRange = t.rangeAtIndex(0)
                return self.substringWithNSRange(range)
        }
        
        var hashtags:[String] = []
        for hashtag in someHashtags {
            if let ht = hashtag {
                hashtags.append(ht)
            }
        }
        return hashtags
    }
    
    /**
    Gets an array of distinct strings (hashtags #acme) for all hashtags found in a String
    
    :returns: [String]
    */
    func getUniqueHashtags() -> [String] {
        return NSSet(array: self.getHashtags()).allObjects as [String]
    }
    
    
    /**
    Gets an array of strings (mentions @apple) for all mentions found in a String
    
    :returns: [String]
    */
    func getMentions() -> [String] {
        let mentionDetector = NSRegularExpression(pattern: "@(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        let results = mentionDetector.matchesInString(self, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, self.utf16Count)) as [NSTextCheckingResult]

        let someMentions = results.map() {
                (t : NSTextCheckingResult) -> String! in
                let range :NSRange = t.rangeAtIndex(0)
            return self.substringWithNSRange(range)
        }
        
        return someMentions.map { $0 }
    }
    
    /**
    Check if a String contains a Date in it.
    
    :returns: Bool with true value if it does
    */
    func containsDate() -> Bool {
        return self.getDates().count > 0
    }
    
    
    /**
    Check if a String contains a link in it.
    
    :returns: Bool with true value if it does
    */
    func containsLink() -> Bool {
        return self.getLinks().count > 0
    }

    /**
    :returns: Base64 encoded string
    */
    func encodeToBase64Encoding() -> String {
        let utf8str = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let base64EncodedString = utf8str.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
        return base64EncodedString
    }
    
    /**
    :returns: Decoded Base64 string
    */
    func decodeFromBase64Encoding() -> String {
        let base64data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.fromRaw(0)!)
        let decodedString = NSString(data: base64data, encoding: NSUTF8StringEncoding)
        return decodedString
    }

    /**
        Float value from a string
    */
    var floatValue: Float {
        return (self as NSString).floatValue
    }

    
}
