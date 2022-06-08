//
//  EnterExitViewModifier.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/18/22.
//

import Foundation
import SwiftUI

struct TouchEnterExit: ViewModifier {
  @GestureState private var dragLocation: CGPoint = .zero
  @State private var didEnter = false

  let onEnter: (() -> Void)?
  let onExit: (() -> Void)?

  func body(content: Content) -> some View {
    content
      .gesture(
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
          .updating($dragLocation) { value, state, _ in
            state = value.location
          }
      )
      .background(GeometryReader { geo in
        dragObserver(geo)
      })
  }

  private func dragObserver(_ geo: GeometryProxy) -> some View {
    if geo.frame(in: .global).contains(dragLocation) {
      DispatchQueue.main.async {
        didEnter = true
        onEnter?()
      }
    } else if didEnter {
      DispatchQueue.main.async {
        didEnter = false
        onExit?()
      }
    }
    return Color.clear
  }
}

extension View {
  func touchEnterExit(onEnter: (() -> Void)? = nil,
                      onExit: (() -> Void)? = nil) -> some View {
    self.modifier(TouchEnterExit(onEnter: onEnter, onExit: onExit))
  }
}
