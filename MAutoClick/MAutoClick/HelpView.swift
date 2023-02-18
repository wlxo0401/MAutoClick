//
//  HelpView.swift
//  MAutoClick
//
//  Created by 김지태 on 2023/02/18.
//

import Foundation
import SwiftUI

struct HelpView: View {
    
    
    // 설명 종류
    enum HelpType: String {
        case usage
        case shortcut
        case autoLocation
        case loopMode
        
        var helpCategory: String {
            switch self {
            case .usage:
                return "Usage"
            case .shortcut:
                return "Shortcut"
            case .autoLocation:
                return "Auto Location"
            case .loopMode:
                return "Loop Mode"
            }
        }
        
        var helpExplain: String {
            switch self {
            case .usage:
                return """
                        1. Choose the action between move and click.
                        
                        2. Enter the location where you want to perform the action.
                        
                        3. Add any delay you want to apply to each action.
                        
                        4. Enter the number of iterations.
                        
                        5. Please press the start button.
                        """
            case .shortcut:
                return """
                        - Command + Shift + C
                        Switch action state between move and click
                        
                        - Command + Shift + A
                        Adds a set action to the list
                        
                        - Command + Shift + D
                        Adds the set delay to the list
                        
                        - Command + Shift + S
                        Start/Stop Features
                        
                        - Command + Shift + L
                        Loop Mode on/off
                        
                        - Command + Shift + P
                        Auto Location on/off
                        """
            case .autoLocation:
                return "With this feature, the location is automatically entered. However, it should be used with shortcuts for better use."
            case .loopMode:
                return "Performs the operation indefinitely without setting the number of iterations. Add delay in the middle for better use."
            }
        }
    }
    
    
    @Binding var isHelpShow: Bool
    @State var selectedExplain: HelpType = .usage
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text("Help")
                        .font(.system(size: 20, weight: .bold))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.all)
                    Divider()
                    
                    
                    
                    ScrollView {
                        self.explainButton(helpType: .usage)
                        self.explainButton(helpType: .shortcut)
                        self.explainButton(helpType: .autoLocation)
                        self.explainButton(helpType: .loopMode)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.all)
                    
                    
                    
                    
                    
                    
                }
                .frame(width: 200)
                
                Divider()
                self.explainView()
            }
            Divider()
            
            Button {
                self.isHelpShow = false
            } label: {
                Text("Close")
            }
            .padding(.all)
        }
        .frame(width: 600, height: 325)
    }
}

//MARK: - Sub View
extension HelpView {
    // Help 목록
    @ViewBuilder
    private func explainButton(helpType: HelpType) -> some View {
        Button {
            self.selectedExplain = helpType
        } label: {
            Text(helpType.helpCategory)
        }
    }
    
    // 설명
    @ViewBuilder
    private func explainView() -> some View {
        VStack {
            Text(self.selectedExplain.helpCategory)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .fontWeight(.heavy)
                .padding(.all)
            
            ScrollView {
                Text(self.selectedExplain.helpExplain)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.bottom)
        }
    }
}


struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(isHelpShow: .constant(true))
    }
}
