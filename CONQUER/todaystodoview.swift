//
//  todaystodoview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 30/12/2023.
//

import SwiftUI

struct todaystodoview: View {
    var body: some View {
        VStack {
            
            VStack {
                HStack {
                    Text("Today's Tasks")
                        .font(.title)
                        .padding(.horizontal)
                        .bold()
                    
                    
                    Spacer()
                    Button(action: dothing, label: {Image(systemName: "calendar")
                            .padding(.horizontal)
                    })
                    Button(action: dothing, label: {
                        Text("+")
                            .padding(.trailing)
                            .font(.system(size: 25))
                        
                    })
                }
                
                HStack {
                    Text(getTodaysDate())
                        .padding(.horizontal)
                    Spacer()
                }
            }
        .padding(.horizontal)
            List {
                todoRow()
                todoRow()
                
            }
        }
    }
}

struct todoRow: View {
    @State var isOn = false
    var body: some View {
        HStack{
            Button(action: dothing, label: {
                Image(systemName: "checkmark.circle")
            })
            Text("DO THIS TING")
            Text("ROY")
                .background(.red)
                .foregroundStyle(.white)
                .safeAreaPadding(.horizontal, 5)
            Text("30 minutes")
                .foregroundStyle(.white)
                .background(.purple)
                .safeAreaPadding(.horizontal, 5)
            
        }
    }
}

func dothing() {
    print("Hello")
}

func getTodaysDate() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter.string(from: .now)
}
#Preview {
    todaystodoview()
}
