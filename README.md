![](splash.png)
# Swift String Tools
A String extension that allows you to do some very awesome functions efforlessly. 

###Functions
Function Name | Description 
--------------|------------
```swift var length ``` | Length of String in Swift
```swift var objclength ``` | Length of NSString, similar to ```.length``` in NSString
```swift func detectLanguage() -> String! ```| Detects the language of a String.
```swift func isRightToleft() -> Bool ```| Check the text direction of a given String.
```swift func isOnlyEmptySpacesAndNewLineCharacters() ->Bool ```| Check that a String is only made of white spaces, and new line characters.
```swift func isTweetable() -> Bool ``` | Check that a String is 'tweetable'; can be used in a tweet.
```swift func getLinks() -> [String] ```| Gets an array of Strings for all links found in a String.
```swift func getURLs() -> [NSURL] ```| Gets an array of URLs for all links found in a String.
```swift func getDates() -> [NSDate] ```| Gets an array of dates for all dates found in a String
```swift func getHashtags() -> [String] ```| Gets an array of strings (hashtags #acme) for all links found in a String.
```swift func getMentions() -> [String] ```| Gets an array of strings (mentions @apple) for all mentions found in a String
```swift func containsDate() -> Bool ```| Check if a String contains a Date in it.
```swift func containsLink() -> Bool ```| Check if a String contains a link in it.
```swift func encodeToBase64Encoding() -> String ```| Encodes a String in Base64 encoding
```swift func decodeFromBase64Encoding() -> String ```| Decode a Base64 encoded String


### License
String Tools is under MIT License. Check the license file for more information.


### Contact Info
follow me on twitter: [@jamal_2](https:///www.twitter.com/jamal_2)
