import SwiftUI

struct ProgressBar: View {
    let value: Float

    var cornerRadius: CGFloat = 2

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .frame(
                    width: min(CGFloat(self.value) * proxy.size.width, proxy.size.width),
                    height: proxy.size.height
                )
                .cornerRadius(cornerRadius)
        }
    }
}
