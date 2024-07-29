<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/header-dark.png"><img src="https://raw.githubusercontent.com/exyte/media/master/common/header-light.png"></picture></a>

<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/our-site-dark.png" width="80" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/our-site-light.png" width="80" height="16"></picture></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://twitter.com/exyteHQ"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/twitter-dark.png" width="74" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/twitter-light.png" width="74" height="16">
</picture></a> <a href="https://exyte.com/contacts"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-dark.png" width="128" height="24" align="right"><img src="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-light.png" width="128" height="24" align="right"></picture></a>

<table>
    <thead>
        <tr>
            <th>Floaters</th>
            <th>Toasts</th>
            <th>Popups</th>
            <th>Sheets</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <img src="https://raw.githubusercontent.com/exyte/media/master/PopupView/1.gif" />
            </td>
            <td>
                <img src="https://raw.githubusercontent.com/exyte/media/master/PopupView/2.gif" />
            </td>
            <td>
                <img src="https://raw.githubusercontent.com/exyte/media/master/PopupView/3.gif" />
            </td>
            <td>
                <img src="https://raw.githubusercontent.com/exyte/media/master/PopupView/4.gif" />
            </td>
        </tr>
    </tbody>
</table>

<p><h1 align="left">Popup View</h1></p>

<p><h4>Toasts, alerts and popups library written with SwiftUI</h4></p>

<a href="https://exyte.com/blog/swiftui-tutorial-popupview-library">Read Article »</a>

![](https://img.shields.io/github/v/tag/exyte/popupView?label=Version)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fexyte%2FPopupView%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/exyte/PopupView)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fexyte%2FPopupView%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/exyte/PopupView)
[![SPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swiftpackageindex.com/exyte/PopupView)
[![Cocoapods Compatible](https://img.shields.io/badge/cocoapods-Compatible-brightgreen.svg)](https://cocoapods.org/pods/ExytePopupView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)

# What's new in version 3
- zoom in/out appear/disappear animations
- `disappearTo` parameter to specify disappearing animation direction - can be different from `appearFrom`

# Update to version 3
To include new .zoom type, `AppearFrom` enum cases were renamed.
Instead of:
```swift
.popup(isPresented: $floats.showingTopFirst) {
    FloatTopFirst()
} customize: {
    $0
        .type(.floater())
        .appearFrom(.top) // <-- here
}
```
use:
```swift
.popup(isPresented: $floats.showingTopFirst) {
    FloatTopFirst()
} customize: {
    $0
        .type(.floater())
        .appearFrom(.topSlide) // <-- here
}
```

# Update to version 2

Instead of:
```swift
.popup(isPresented: $floats.showingTopFirst, type: .floater(), position: .top, animation: .spring(), closeOnTapOutside: true, backgroundColor: .black.opacity(0.5)) {
    FloatTopFirst()
}
```
use:
```swift
.popup(isPresented: $floats.showingTopFirst) {
    FloatTopFirst()
} customize: {
    $0
        .type(.floater())
        .position(.top)
        .animation(.spring())
        .closeOnTapOutside(true)
        .backgroundColor(.black.opacity(0.5))
}
```
Using this API you can pass parameters in any order you like.

# Show over navbar
To display your popup over all other views including navbars please use:
```swift
.popup(isPresented: $floats.showingTopFirst) {
    FloatTopFirst()
} customize: {
    $0.isOpaque(true)
}
```
This will also mean that you won't be able to tap "through" the popup's background on any of the controls "behind it" (that's because this method actually uses transparent fullscreenSheet, which won't pass the touches to underlying view). Opaque popup uses screen size to calculate its position.   

Unfortunately, if opaque is false (to allow "through-touches" if you need them), popup - even if forced to be fullscreen, will be displayed under the navbar (if you know how to pass over this restriction, please do let me know in the comments). Please keep in mind that in this case the popup calculates its position using the frame of the view you attach it to, to avoid being under the navbar. So you'll likely want to attach it to the root view of your app.  

# Usage
1. Add a bool to control popup presentation state
2. Add `.popup` modifier to your view. 
```swift
import PopupView

struct ContentView: View {

    @State var showingPopup = false

    var body: some View {
        YourView()
            .popup(isPresented: $showingPopup) {
                Text("The popup")
                    .frame(width: 200, height: 60)
                    .background(Color(red: 0.85, green: 0.8, blue: 0.95))
                    .cornerRadius(30.0)
            } customize: {
                $0.autohideIn(2)
            }
    }
}
```

### Required parameters 
`isPresented` - binding to determine if the popup should be seen on screen or hidden     
`view` - view you want to display on your popup  

#### or
`item` - binding to item: if item's value is nil - popup is hidden, if non-nil - displayed. Be careful - library makes a copy of your item during dismiss animation!!     
`view` - view you want to display on your popup  

### Available customizations - optional parameters
use `customize` closure in popup modifier:

`type`:
- `default` - usual popup in the center of screen
- toast - fitted to screen i.e. without padding and ignoring safe area
- floater - has padding and can choose to use or ignore safe area
- scroll - adds a scroll to your content, if you scroll to top of this scroll - the gesture will continue into popup's drag dismiss.

floater parameters:     
- `verticalPadding` - padding which will define padding from the relative vertical edge or will be added to safe area if `useSafeAreaInset` is true   
- `horizontalPadding` - padding which will define padding from the relative horizontal edge or will be added to safe area if `useSafeAreaInset` is true      
- `useSafeAreaInset` - whether to include safe area insets in floater padding      

scroll parameters:   
`headerView` - a view on top which won't be a part of the scroll (if you need one)

`position` - topLeading, top, topTrailing, leading, center, trailing, bottomLeading, bottom, bottomTrailing 
`appearFrom` - `topSlide, bottomSlide, leftSlide, rightSlide, centerScale`: determines the direction of appearing animation. If left empty it copies `position` parameter: so appears from .top edge, if `position` is set to .top
`disappearTo` - same as `appearFrom`, but for disappearing animation. If left empty it copies `appearFrom`.
`animation` - custom animation for popup sliding onto screen  
`autohideIn` - time after which popup should disappear    
`dragToDismiss` - true by default: enable/disable drag to dismiss (upwards for .top popup types, downwards for .bottom and default type)    
`closeOnTap` - true by default: enable/disable closing on tap on popup     
`closeOnTapOutside` - false by default: enable/disable closing on tap on outside of popup     
`backgroundColor` - Color.clear by default: change background color of outside area     
`backgroundView` - custom background builder for outside area (if this one is set `backgroundColor` is ignored)    
`isOpaque` - false by default: if true taps do not pass through popup's background and the popup is displayed on top of navbar. For more see section "Show over navbar"     
`useKeyboardSafeArea` - false by default: if true popup goes up for keyboardHeight when keyboard is displayed
`dismissCallback` - custom callback to call once the popup is dismissed      

### Draggable card - sheet
To implement a sheet (like in 4th gif) enable `dragToDismiss` on bottom toast (see example project for implementation of the card itself)
```swift
.popup(isPresented: $show) {
    // your content 
} customize: {
    $0
        .type (.toast)
        .position(bottom)
        .dragToDismiss(true)
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

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/PopupView.git")
]
```

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

## Requirements

* iOS 15.0+ / macOS 11.0+ / tvOS 14.0+ / watchOS 7.0+
* Xcode 12+ 

## Our other open source SwiftUI libraries
[Grid](https://github.com/exyte/Grid) - The most powerful Grid container    
[ScalingHeaderScrollView](https://github.com/exyte/ScalingHeaderScrollView) - A scroll view with a sticky header which shrinks as you scroll    
[AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - A tabbar with a number of preset animations   
[MediaPicker](https://github.com/exyte/mediapicker) - Customizable media picker     
[Chat](https://github.com/exyte/chat) - Chat UI framework with fully customizable message cells, input view, and a built-in media picker  
[OpenAI](https://github.com/exyte/OpenAI) Wrapper lib for [OpenAI REST API](https://platform.openai.com/docs/api-reference/introduction)    
[AnimatedGradient](https://github.com/exyte/AnimatedGradient) - Animated linear gradient     
[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding) - Animated onboarding flow    
[FloatingButton](https://github.com/exyte/FloatingButton) - Floating button menu    
[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView) - A number of animated loading indicators    
[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView) - A number of animated progress indicators    
[FlagAndCountryCode](https://github.com/exyte/FlagAndCountryCode) - Phone codes and flags for every country    
[SVGView](https://github.com/exyte/SVGView) - SVG parser    
[LiquidSwipe](https://github.com/exyte/LiquidSwipe) - Liquid navigation animation    
