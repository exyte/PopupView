//
//  Floats.swift
//  Example
//
//  Created by Alex.M on 19.05.2022.
//

import SwiftUI

struct FloatTopFirst: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "E0E3E8"))
            
            HStack(spacing: 0) {
                Image("avatar1")
                    .aspectRatio(1.0, contentMode: .fit)
                    .cornerRadius(16)
                    .padding(16.0)
                
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        Text("Adam Jameson")
                            .bold()
                            .foregroundColor(.black) +
                        Text(" invites you to join his training")
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    Button {
                        debugPrint("Accepted!")
                    } label: {
                        Text("Accept".uppercased())
                            .font(.system(size: 14, weight: .black))
                    }
                    .customButtonStyle(foreground: Color(hex: "9265F8"), background: .clear)
                }
                
                Spacer()
            }
        }
        .frame(height: 98)
        .padding(.horizontal, 16)
    }
}

struct FloatTopSecond: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("We give you a gift!")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                
                Text("30% discount until the end of the month on all products of the company.")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .opacity(0.8)
            }
            
            Spacer()
            
            Image("gift")
                .aspectRatio(1.0, contentMode: .fit)
        }
        .padding(16)
        .background(Color(hex: "9265F8").cornerRadius(12))
        .shadow(color: Color(hex: "9265F8").opacity(0.5), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}

struct FloatBottomFirst: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Your message has been sent to Alex Brant")
                .font(.system(size: 15))
                .foregroundColor(.black)
            Spacer()
            Image("avatar2")
                .frame(width: 32, height: 32)
                .cornerRadius(16)
        }
        .padding(16)
        .background(Color.white.cornerRadius(12))
        .shadowedStyle()
        .padding(.horizontal, 16)
    }
}

struct FloatBottomSecond: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            
            Text("Check your network connection and try again")
                .foregroundColor(.white)
                .font(.system(size: 16))
        }
        .padding(16)
        .background(Color(hex: "FFB93D").cornerRadius(12))
        .padding(.horizontal, 16)
    }
}

struct Floats_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            VStack {
                FloatTopFirst()
                FloatTopSecond()
                FloatBottomFirst()
                FloatBottomSecond()
            }
        }
    }
}
