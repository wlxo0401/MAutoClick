//
//  ContentView.swift
//  MAutoClick
//
//  Created by 김지태 on 2023/02/15.
//

import SwiftUI

struct ContentView: View {
    
    
    var mouseLocation: NSPoint {
        NSEvent.mouseLocation
    }
    
    

    
    
    @State var overImg = false
    
    
    var body: some View {
        
        ZStack {
            
            VStack {

                Image(systemName: "clock").resizable().frame(width: 200, height: 200)
                            .onHover { over in
                                overImg = over
                            }
                            .onAppear(perform: {
                                NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                                    if overImg {
                                        print("mouse: \(self.mouseLocation.x) \(self.mouseLocation.y)")
                                    }
                                    return $0
                                }
                            })
                
                GeometryReader { geometry in
                    VStack {
                        Text("\(geometry.size.width) x \(geometry.size.height)")
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                }
                
                Text("Mouse \nLocationX : \(mouseLocation.x), \nLocationY : \(mouseLocation.y)")
                
                
                Button {
                    
                    if let screen = NSScreen.main {
                        let rect = screen.frame
                        let height = rect.size.height
                        let width = rect.size.width
                        
                        let source = CGEventSource.init(stateID: .hidSystemState)
//                        let position = NSPoint(x: 1521.18, y: height - 1570.183)
//                        let position = NSPoint(x: 1521.18, y: height - 1672.281)
                        let position = CGPoint(x: 848, y: height - 435)
                        
                        print(CGPoint(x: mouseLocation.x, y: height - mouseLocation.y))
                        let eventDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: position , mouseButton: .left)
                        
                        
                        let positionTwo = CGPoint(x: 800, y: height - 435)
                        let eventMove = CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: positionTwo , mouseButton: .left)
                        
                        let eventUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: positionTwo , mouseButton: .left)

                        eventDown?.post(tap: .cghidEventTap)
                        usleep(500_000)
                        eventMove?.post(tap: .cghidEventTap)
                        usleep(500_000)
                        eventUp?.post(tap: .cghidEventTap)
                    }
                    
              
                } label: {
                    Text("나를 눌러")
                }

            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
