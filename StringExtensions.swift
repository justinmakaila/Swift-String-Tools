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

// MARK:
// MARK: String Extensions
// MARK:

extension String {
    
    // MARK: Variables
    
    /**
       The length of the string.
     */
    var length: Int {
        return countElements(self)
    }
    
    /**
       The UTF16 length of the string.
     */
    var objcLength: Int {
        // ???: Would it be easier/different to cast to NSString and use .length?
        return self.utf16Count
    }
    
    /**
       Indicates if the string is an Email via NSDataDetector
     */
    var isEmail: Bool {
        let dataDetector = NSDataDetector(types: NSTextCheckingType.Link.toRaw(), error: nil),
            firstMatch = dataDetector.firstMatchInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, self.length))
            
            return (firstMatch?.range.location != NSNotFound && firstMatch?.URL?.scheme == "mailto")
    }
    
    /**
      Converts self to Float.
    
      :return: Float representation of self.
    */
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    // MARK: Utilities
    // MARK: Linguistics
    
    /**
       Returns the langauge of a String.
     
       :discussion: String has to be at least 4 characters, otherwise the method will return nil.
     
       :return: String? representing the langague of the string (e.g. en, fr, or und for undefined).
     */
    func detectLanguage() -> String? {
        // ???: Is there a reason why 4 letters is required? If so, a note should be made in the discussion section.
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
     
       :discussion: String has to be at least 4 characters, otherwise the method will return false.
     
       :return: Bool true if the string was writting in a right to left langague (e.g. Arabic, Hebrew)
     */
    func isRightToLeft() -> Bool {
        let language = self.detectLanguage()
        return (language? == "ar" || language? == "he")
    }
    
    /**
       Check that a String is only made of white spaces, and new line characters.
     
       :return: Bool indicating if the string is empty characters.
     */
    func isOnlyEmptySpacesAndNewLineCharacters() -> Bool {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).length == 0
    }
    
    // MARK: Social
    
    /**
       Check that a String is 'tweetable'; can be used in a tweet.
     
       :return: Bool indicating if self is tweetable.
     */
    func isTweetable() -> Bool {
        let tweetLength = 140,
            // ???: Why multiply by 23?
            linksLength = self.getLinks().count * 23,
            remaining = tweetLength - linksLength
        
        if linksLength != 0 {
            return remaining < 0
        } else {
            return !(self.utf16Count > tweetLength || self.utf16Count == 0 || self.isOnlyEmptySpacesAndNewLineCharacters())
        }
    }
    
    /**
      Gets an array of URLs for all links found in self.
    
      :return: [NSURL] representing the URLs found in self
    */
    func getURLs() -> [NSURL] {
        let error: NSErrorPointer = NSErrorPointer(),
        detector: NSDataDetector = NSDataDetector(types: NSTextCheckingType.Link.toRaw(), error: error),
        links = detector.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, self.utf16Count)) as [NSTextCheckingResult]
        
        return links.filter { link in
            return link.URL != nil
        }.map { link -> NSURL in
            return link.URL!
        }
    }
    
    /**
       Gets an array of Strings for all links found in self.
     
       :discussion: Uses getURLs() internally, returning the absoluteString
                    of each URL.
     
       :return: [String] representing the links found in self
     */
    func getLinks() -> [String] {
        return getURLs().map { url -> String in
            return url.absoluteString!
        }
    }
    
    /**
       Gets an array of dates for all dates found in self.
     
       :return: [NSDate]
     */
    func getDates() -> [NSDate] {
        let error: NSErrorPointer = NSErrorPointer(),
            detector: NSDataDetector = NSDataDetector(types: NSTextCheckingType.Date.toRaw(), error: error),
            links = detector.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, self.utf16Count)) as [NSTextCheckingResult]

        return links.filter { link in
            return link.date != nil
        }.map { link -> NSDate in
            return link.date!
        }
    }
    
    /**
       Gets an array of hashtags found in self.
     
       :param: includeDevice a Bool indicating whether or not the hashtag device (#) should
               be included in the results. Default is true.
     
       :discussion: Returns an empty array if there are no matches.
     
       :return: [String] of substrings matching the regex #(\w+).
     */
    func getHashtags(includeDevice: Bool = true) -> [String] {
        return self.getMatchesForPrefix("#", includePrefix: includeDevice)
    }
    
    /**
       Gets an array of unique hashtags found in self.
     
       :param: includeDevice a Bool indicating whether or not the hashtag device (#) should
              be included in the results. Default is true.
     
       :return: [String] of unique substrings matching the regex #(\w+).
     */
    func getUniqueHashtags(includeDevice: Bool = true) -> [String] {
        return NSSet(array: self.getHashtags(includeDevice: includeDevice)).allObjects as [String]
    }
    
    /**
       Gets an array of mentions found in self.
     
       :param: includeDevice a Bool indicating whether or not the mention device (@) should
              be included in the results. Default is true.
     
       :discussion: Returns an empty array if no matches are found.
     
       :return: [String] of substrings matching the regex @(\w+).
     */
    func getMentions(includeDevice: Bool = true) -> [String] {
        return self.getMatchesForPrefix("@", includePrefix: includeDevice)
    }
    
    /**
       Gets an array of unique mentions found in self.
     
       :param: includeDevice a Bool indicating whether or not the mention device (@) should
              be included in the results. Default is true.
     
       :return: [String] of unique substrings matching the regex @(\w+).
     */
    func getUniqueMentions(includeDevice: Bool = true) -> [String] {
        return NSSet(array: self.getMentions(includeDevice: includeDevice)).allObjects as [String]
    }
    
    /**
       Gets an array of strings with the prefix.
     
       :param: prefix The prefix to search for.
       :param: includePrefix Bool indicating whether or not the prefix should be included
              in the results. Default is true.
     
       :discussion: Internally uses getMatchesForRegex(...). Returns an empty array if no
                   matches are found.
     
       :return: [String] of substrings matching the regex "`prefix`(\w+)".
     */
    func getMatchesForPrefix(prefix: String, includePrefix: Bool = true) -> [String] {
        if let results = self.getMatchesForRegex("\(prefix)(\\w+)") {
            if includePrefix == true {
                return results
            } else {
                return results.map { result -> String in
                    return result[1..<result.length]
                }
            }
        }
        
        return [String]()
    }
    
    /**
       Gets an array of strings matching `regex` found in self.
     
       :param: regex The regex pattern to use for matching.
       :param: options The NSRegularExpressionOptions to be used for matching.
                      Default is NSRegularExpressionOptions.CaseInsensitive.
     
       :discussion: If `regex` is not a valid regular expression pattern, this will return nil.
     
       :return: [String]? an array of String objects matching `regex`
     */
    func getMatchesForRegex(regex: String, options: NSRegularExpressionOptions = .CaseInsensitive) -> [String]? {
        var error: NSError?
        let regularExpression = NSRegularExpression(pattern: regex, options: options, error: &error)
        
        if error == nil {
            if let results = regularExpression.matchesInString(self, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, self.utf16Count)) as? [NSTextCheckingResult] {
                return results.map { textCheckingResult -> String in
                    return self[textCheckingResult.rangeAtIndex(0)]
                }
            }
        }
        
        return nil
    }
    
    /**
       Checks if self contains a date.
     
       :return: Bool true if there is a date present, else false.
     */
    func containsDate() -> Bool {
        return self.getDates().count > 0
    }
    
    /**
       Check if a String contains a link in it.
     
       :return: Bool true if there is a link present, else false.
     */
    func containsLink() -> Bool {
        return self.getLinks().count > 0
    }

    /**
       Encodes self to Base64.
     
       :return: String self encoded to Base64.
     */
    func encodeBase64() -> String {
        let utf8str = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        return utf8str.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
    }
    
    /**
       Decodes self from Base64.
     
       :return: String self decoded from Base64
     */
    func decodeBase64() -> String {
        let base64data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.fromRaw(0)!)
        
        return NSString(data: base64data, encoding: NSUTF8StringEncoding)
    }
}

// MARK: Subscript Methods

extension String {
    /**
       Allows subscript access to characters in self
       by integers.
     */
    subscript (index: Int) -> String {
        return String(Array(self)[index])
    }
    
    /**
       Allows subscript access to characters in self
       using integer Ranges.
     */
    subscript (range: Range<Int>) -> String {
        var start = advance(startIndex, range.startIndex),
            end = advance(startIndex, range.endIndex)
            
        return substringWithRange(Range(start: start, end: end))
    }
    
    /**
       Allows subscript access to characters in self
       using NSRange.
     */
    subscript (range: NSRange) -> String {
        let end = range.location + range.length
        return self[Range(start: range.location, end: end)]
    }
    
    /**
       Allows subscript access to characters in self
       using a String parameter to represent a substring.
     */
    subscript (substring: String) -> Range<String.Index>? {
        return rangeOfString(substring, options: NSStringCompareOptions.LiteralSearch, range: Range(start: startIndex, end: endIndex), locale: NSLocale.currentLocale())
    }
}

// MARK:
// MARK:  NSString Extensions
// MARK:

// MARK: Subscript Methods

extension NSString {
    /**
       Allows subscript access to characters in self
       using a String parameter to represent a substring.
     */
    subscript (substring: String) -> NSRange? {
        return rangeOfString(substring)
    }
    
    /**
       Allows subscript access to characters in self
       using a NSString parameter to represent a substring.
     */
    subscript (substring: NSString) -> NSRange? {
        return self[(substring as String)]
    }
}
