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
            HStack {
                Text("Today's Tasks")
                    .font(.title)
                    .padding()
                    .bold()
                Spacer()
            }
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
                .safeAreaPadding(.horizontal, 5)
            Text("30 minutes")
                .background(.purple)
                .safeAreaPadding(.horizontal, 5)
            
        }
        VStack {
            List {
                Text("fefe")
                Text("JOE")
            }.listStyle(.plain)
                
            
        }
    }
}

func dothing() {
    print("Hello")
}
#Preview {
    todaystodoview()
}
