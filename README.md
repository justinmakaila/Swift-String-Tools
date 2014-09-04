![](splash.png)
# Swift String Tools
A String extension that allows you to do some very awesome functions efforlessly. 

###Functions

####String
Function Name | Description 
--------------|------------
```var length: Int``` | Length of String in Swift
```var objclength: Int``` | Length of NSString, similar to ```.length``` in NSString
```var isEmail: Bool``` | Uses NSDataDetector to determine if the String is an email address.
```var floatValue: Float``` | Returns the Float value of the String.
```func detectLanguage() -> String? ``` | Detects the language of self.
```func isRightToleft() -> Bool ``` | Check the text direction of self.
```func isOnlyEmptySpacesAndNewLineCharacters() ->Bool ``` | Check that self is only made of white spaces, and new line characters.
```func isTweetable() -> Bool ``` | Check if self can be used in a tweet.
```func getLinks() -> [String] ``` | Gets an array of Strings for all links found in self.
```func getURLs() -> [NSURL] ``` | Gets an array of URLs for all links found in self.
```func getDates() -> [NSDate] ``` | Gets an array of dates for all dates found in self.
```func getHashtags(includeDevice: Bool = true) -> [String] ``` | Gets an array of hashtags found in self.
```func getUniqueHashtags(includeDevice: Bool = true) -> [String]``` | Gets an array of unique hashtags found in self.
```func getMentions(includeDevice: Bool = true) -> [String] ``` | Gets an array of mentions found in self.
```func getUniqueMentions(includeDevice: Bool = true) -> [String]``` | Gets an array of unique mentions found in self.
```func getMatchesForPrefix(prefix: String, includePrefix: Bool = true) -> [String]``` | Gets an array of substrings matching `prefix`.
```func getMatchesForRegex(regex: String, options: NSRegularExpressionOptions = .CaseInsensitive) -> [String]?``` | Gets an array of substrings matching `regex` using the options provided by `options`. Returns nil if `regex` is invalid.
```func containsDate() -> Bool ``` | Check if a String contains a Date in it.
```func containsLink() -> Bool ``` | Check if a String contains a link in it.
```func encodeBase64() -> String ``` | Encodes self to Base64.
```func decodeBase64() -> String ``` | Decode self from Base64.
```subscript[index: Int] -> String ``` | Returns the substring at `index`.
```subscript[range: Range<Int>] -> String ``` | Returns the substring that falls within `range`
```subscript[range: NSRange] -> String ``` | Returns the substring that falls within `range`
```subscript[substring: String] -> Range<String.Index>? ``` | Returns the range of `substring` within self.

####NSString
Function Name | Description
--------------|------------
```subscript[substring: String] -> NSRange? ``` | Returns the `NSRange` of `substring`
```subscript[substring: NSString] -> NSRange? ``` | Returns the `NSRange` of `substring`


### License
String Tools is under MIT License. Check the license file for more information.


### Contact Info
Follow us on Twitter: [@jamal_2](https:///www.twitter.com/jamal_2), [@justinmakaila](https://www.twitter.com/justinmakaila)
