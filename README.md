<img src="https://github.com/exyte/PopupView/blob/master/Assets/header.png">
<img align="right" src="https://raw.githubusercontent.com/exyte/PopupView/master/Assets/demo.gif" width="480" />

<p><h1 align="left">Popup View</h1></p>

<p><h4>Toasts, alerts and popups library written with SwiftUI</h4></p>

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
1. Add a binding bool to control popup presentation state
1. Add `.popup` modifier to your view
```swift
struct ContentView: View {

    @State var showingPopup = false

    var body: some View {
        YourView()
            .popup(isPresented: $showingPopup, autohideIn: 2) {
                Text("The popup")
                    .frame(width: 200, height: 60)
                    .background(Color(red: 0.85, green: 0.8, blue: 0.95))
                    .cornerRadius(30.0)
            }
    }
}
```

### Required parameters 
`isPresented` - binding to determine if the popup should be seen on screen or hidden     
`view` - view you want to display on your popup  

### Available customizations - optional parameters  
`type` - toast, float or default. Floater has parameters of its own: 
        `verticalPadding`  - padding which will define padding from the top or will be added to safe area if `useSafeAreaInset` is true
        `useSafeAreaInset` - whether to include safe area insets in floater padding     
`position` - top or bottom (for default case it just determines animation direction)  
`animation` - custom animation for popup sliding onto screen  
`autohideIn` - time after which popup should disappear    
`dragToDismiss` - true by default: enable/disable drag to dismiss (upwards for .top popup types, downwards for .bottom and default type)    
`closeOnTap` - true by default: enable/disable closing on tap on popup     
`closeOnTapOutside` - false by default: enable/disable closing on tap on outside of popup     
`backgroundColor` - Color.clear by default: change background color of outside area     
`dismissCallback` - custom callback to call once the popup is dismissed      

<img align="right" src="https://raw.githubusercontent.com/exyte/PopupView/master/Assets/drag.gif" width="480" />

### Draggable card
With latest addition of `dragToDismiss`, you can use bottom toast to add this popular component to your app (see example project for implementation)
```swift
.popup(isPresented: $show, type: .toast, position: .bottom) {
    // your content
}
```

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
    .package(url: "https://github.com/exyte/PopupView.git", from: "1.0.0")
]
```

### Manually

Drop [PopupView.swift](https://github.com/exyte/PopupView/blob/master/Source/PopupView.swift) in your project.

## Requirements

* iOS 13+
* Xcode 11+ 
