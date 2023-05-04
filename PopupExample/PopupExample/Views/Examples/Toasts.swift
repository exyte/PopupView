//
//  Toasts.swift
//  Example
//
//  Created by Alex.M on 19.05.2022.
//

import SwiftUI

struct ToastTopFirst: View {
    var body: some View {
        Text("Unable to add to bag as this item is currently not available.")
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 60, leading: 32, bottom: 16, trailing: 32))
            .frame(maxWidth: .infinity)
            .background(Color(hex: "FE504E"))
    }
}

struct ToastTopSecond: View {
    var body: some View {
        HStack {
            Image("avatar3")
                .frame(width: 48, height: 48)
                .cornerRadius(24)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Camila Morrone")
                        .font(.system(size: 15))
                    
                    Spacer()
                    
                    Text("now")
                        .font(.system(size: 13))
                        .opacity(0.6)
                }
                
                Text("Let's go have a cup of coffee! ☕️")
                    .font(.system(size: 15, weight: .light))
            }
        }
        .foregroundColor(.white)
        .padding(EdgeInsets(top: 56, leading: 16, bottom: 16, trailing: 16))
        .frame(maxWidth: .infinity)
        .background(Color(hex: "87B9FF"))
    }
}

struct ToastBottomFirst: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image("fitness")
                .frame(width: 48, height: 48)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Log In to Fitness First")
                    .font(.system(size: 16, weight: .bold))
                Text("To continue training, you need to Log in or Sign up")
                    .font(.system(size: 16))
                    .opacity(0.8)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Button {
                    self.isShowing = false
                } label: {
                    Text("Log in")
                        .frame(width: 112, height: 40)
                }
                .customButtonStyle(foreground: .white, background: Color(hex: "87B9FF"))
                .cornerRadius(8)

                Button {
                    self.isShowing = false
                } label: {
                    Text("Sign up")
                        .frame(width: 112, height: 40)
                }
                .customButtonStyle()
            }
        }
        .foregroundColor(.black)
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 42, trailing: 16))
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct ToastBottomSecond: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image("checkmark")
                .frame(width: 48, height: 48)
                .cornerRadius(24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Subscription completed!")
                    .font(.system(size: 16, weight: .bold))
                Text("The next charge to your credit card will be made on May 25, 2022.")
                    .font(.system(size: 16, weight: .light))
                    .opacity(0.8)
            }
            
            Spacer()
        }
        .foregroundColor(.black)
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 42, trailing: 16))
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 40, x: 0, y: -4)
    }
}

struct Toasts_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            VStack {
                ToastTopFirst()
                ToastTopSecond()
                ToastBottomFirst(isShowing: Binding<Bool>.init(get: { true }, set: { _ in }))
                ToastBottomSecond()
            }
        }
        .previewDevice("iPhone 13 Pro Max")
    }
}



