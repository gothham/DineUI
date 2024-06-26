//
//  MenuDetailView.swift
//  Dine
//
//  Created by doss-zstch1212 on 04/06/24.
//
import SwiftUI

struct MenuDetailView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    var menuItem: MenuItem
    @State var description: String = ""
    
    var body: some View {
        ScrollView {
            if isLandscape {
                MenuDetailCompactView(menuItem: menuItem)
            } else {
                MenuDetailRegularView(menuItem: menuItem, description: $description)
            }
        }
    }
}

struct MenuDetailRegularView: View {
    var menuItem: MenuItem
    @Binding var description: String
    
    var body: some View {
        VStack {
            Image("burger")
                .frame(width: 300, height: 300)
                .clipShape(.rect(cornerRadius: 30))
            
            Text(menuItem.name)
                .font(.title)
            
            Text("$\(String(menuItem.price))")
                .font(.title3)
            
            VStack {
                Text("About")
                    .font(.headline)
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.center)
                
                TextEditor(text: $description)
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
    }
}

struct MenuDetailCompactView: View {
    var menuItem: MenuItem

    var body: some View {
        HStack {
            Image("burger")
                .frame(width: 300, height: 300)
                .clipShape(.rect(cornerRadius: 30))
            
            VStack(alignment: .leading) {
                Text(menuItem.name)
                    .font(.largeTitle)

                Text("$\(String(menuItem.price))")
                    .font(.title3)

                Text("About")
                    .font(.headline)
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
    }
}

// Custom view modifier to track rotation
/*struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// View extension for easy use of the rotation modifier
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}*/

// Preview
#Preview {
    MenuDetailView(
        menuItem: MenuItem(
            name: "Mac n Cheese",
            price: 7.9,
            category: MenuCategory(
                id: UUID(),
                categoryName: "Starter"
            )
        )
    )
}
