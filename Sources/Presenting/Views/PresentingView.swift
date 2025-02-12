//
//  PresentingView.swift
//
//  Created by James Sedlacek on 12/18/23.
//

import SwiftUI

public struct PresentingView<RootView: View, Routes: ViewDisplayable>: View {
    @StateObject private var presenter: Presenter<Routes> = .init()
    private let rootView: (Presenter<Routes>) -> RootView

    public init(_ routeType: Routes.Type, @ViewBuilder rootView: @escaping (Presenter<Routes>) -> RootView) {
        self.rootView = rootView
    }

    public var body: some View {
        rootView(presenter)
            .sheet(item: $presenter.sheet) {
                $0.viewToDisplay
                    .environmentObject(presenter)
            }
            .iflet(presenter.alert) { rootView, alert  in
                rootView.alert(isPresented: presenter.isAlertPresented) {
                    alert
                }
            }
            .iflet(presenter.toastConfig) { rootView, toastConfig in
                rootView.toast(config: toastConfig,
                               onCompletion: presenter.dismissToast)
            }
#if !os(macOS)
            .fullScreenCover(item: $presenter.fullScreenCover) {
                $0.viewToDisplay
                    .environmentObject(presenter)
            }
#endif
    }
}

