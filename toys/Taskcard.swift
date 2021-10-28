//
//  Taskcard.swift
//  toys
//
//  Created by 이상현 on 2021/10/28.
//

import Foundation
import SwiftUI

struct Taskcard: View {
    
    var Content: String
    var due: Date
    var bgColor: Color
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd - hh:mm a"
        return formatter
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            ZStack{
                Color.creamBlack.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0){
                    Divider().opacity(0)
                    Text("\(Content)")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .lineLimit(1)
                    
                    Text("due: \(due, formatter: dateFormatter)")
                        .font(.footnote)
                        .foregroundColor(.white)
                }
                .background(bgColor)
            }
            .frame(width: 300, height: 200, alignment: .center)
        } 
    }
}
