<img src="https://github.com/exyte/PopupView/blob/master/Assets/header.png">
<img align="right" src="https://raw.githubusercontent.com/exyte/PopupView/master/Assets/demo.gif" width="480" />

<p><h1 align="left">Popup View</h1></p>

<p><h4>Toasts and popups library written with SwiftUI</h4></p>

___

<p> We are a development agency building
  <a href="https://clutch.co/profile/exyte#review-731233?utm_medium=referral&utm_source=github.com&utm_campaign=phenomenal_to_clutch">phenomenal</a> apps.</p>

</br>

<a href="https://exyte.com/contacts"><img src="https://i.imgur.com/vGjsQPt.png" width="134" height="34"></a> <a href="https://twitter.com/exyteHQ"><img src="https://i.imgur.com/DngwSn1.png" width="165" height="34"></a>

</br></br>

[![Twitter](https://img.shields.io/badge/Twitter-@exyteHQ-blue.svg?style=flat)](http://twitter.com/exyteHQ)
[![Version](https://img.shields.io/cocoapods/v/ExytePopupView.svg?style=flat)](http://cocoapods.org/pods/ExytePopupView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ExytePopupView.svg?style=flat)](http://cocoapods.org/pods/ExytePopupView)
[![Platform](https://img.shields.io/cocoapods/p/ExytePopupView.svg?style=flat)](http://cocoapods.org/pods/ExytePopupView)

# Usage
1. Put all your body code into a ZStack
2. Add a binding bool to control popup presentation state
3. Add `.popup` modifier to your ZStack
```swift
@State var showingPopup = false

struct ContentView: View {
    var body: some View {
        ZStack {
            // your view
        }
        .popup(isPresented: $showingPopup, autohideIn: 2) {
            HStack {
                Text("The popup")
            }
            .frame(width: 200, height: 60)
            .background(Color(red: 0.85, green: 0.8, blue: 0.95))
            .cornerRadius(30.0)
        }
    }
}
```

### Required parameters 
`presented` - binding to determine if the popup should be seen on screen or hidden     
`view` - view you want to display on your popup  

### Available customizations - optional parameters    
`type` - toast, float or default   
`position` - top or bottom (for default case it just determines animation direction)  
`animation` - custom animation for popup sliding onto screen  
`autohideIn` - time after which popup should disappear    

## Examples

To try PopupView examples:
- Clone the repo `https://github.com/exyte/PopupView.git`
- Open terminal and run `cd <PopupViewRepo>/Example/`
- Run `pod install` to install all dependencies
- Run open `PopupViewExample.xcworkspace/` to open project in the Xcode
- Try it!

## Installation

### [CocoaPods](http://cocoapods.org)

To install `PopupView`, simply add the following line to your Podfile:

```ruby
pod 'ExytePopupView'
```

### [Carthage](http://github.com/Carthage/Carthage)

To integrate `PopupView` into your Xcode project using Carthage, specify it in your `Cartfile`

```ogdl
github "Exyte/PopupView"
```

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/PopupView.git", from: "0.0.1")
]
```

### Manually

Drop [PopupView.swift](https://github.com/exyte/PopupView/blob/master/Source/PopupView.swift) in your project.

## Requirements

* iOS 13+
* Xcode 11+ 
