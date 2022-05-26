//
//  Popups.swift
//  Example
//
//  Created by Alex.M on 20.05.2022.
//

import SwiftUI

struct PopupMiddle: View {

    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image("winner")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 226, maxHeight: 226)
            
            Text("Congratulations!")
                .foregroundColor(.black)
                .font(.system(size: 24))
                .padding(.top, 12)
            
            Text("In two weeks, you did 12 workouts and burned 2671 calories. That's 566 calories more than last month. Continue at the same pace and the result will please you.")
                .foregroundColor(.black)
                .font(.system(size: 16))
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            Button("Thanks") {
                isPresented = false
            }
            .buttonStyle(.plain)
            .font(.system(size: 18, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .foregroundColor(.white)
            .background(Color(hex: "9265F8"))
            .cornerRadius(12)
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color.white.cornerRadius(20))
        .shadowedStyle()
        .padding(.horizontal, 40)
    }
}

struct PopupBottomFirst: View {

    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Policy changes")
                .foregroundColor(.black)
                .font(.system(size: 24))
            
            Text("Policy change occurs through interactions between wide external changes or shocks to the political system and the success of the ideas in the coalitions, which may cause actors in the advocacy coalition to shift coalitions.")
                .foregroundColor(.black)
                .font(.system(size: 16))
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Button("Ok, I accept") {
                isPresented = false
            }
            .buttonStyle(.plain)
            .font(.system(size: 18, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundColor(.white)
            .background(Color(hex: "FFB93D"))
            .cornerRadius(12)
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color.white.cornerRadius(20))
        .shadowedStyle()
        .padding(.horizontal, 16)
    }
}

struct PopupBottomSecond: View {

    var body: some View {
        VStack(spacing: 12) {
            Image("chest")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 156, maxHeight: 156)
            
            Text("Personal offer")
                .foregroundColor(.black)
                .font(.system(size: 24))
                .padding(.top, 4)
            
            Text("Say hello to flexible funding – you're pre-screened for an exclusive personal loan offer through TD Bank. Enter your Personal Offer Code to get started.")
                .foregroundColor(.black)
                .font(.system(size: 16))
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            
            Text("Read More")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "3DDCFF"), Color(hex: "CD3DFF")]),
                        startPoint: .top,
                        endPoint: .bottom))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.horizontal, 64)
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color.white.cornerRadius(20))
        .shadowedStyle()
    }
}


struct Popups_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            PopupMiddle(isPresented: .constant(true))
        }
        
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            PopupBottomFirst(isPresented: .constant(false))
        }
        
        ZStack {
            Rectangle()
                .ignoresSafeArea()
            PopupBottomSecond()
        }
    }
}

