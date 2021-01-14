import SwiftUI

struct CourseThumbnailView: View {
    let thumbnailData: Data?

    var cornerRadius: CGFloat = 8
    var defaultImage = Image("courseThumbnail")

    private var image: Image {
        guard let thumbnailData = self.thumbnailData,
              let uiImage = UIImage(data: thumbnailData) else {
            return self.defaultImage
        }

        return Image(uiImage: uiImage)
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .cornerRadius(cornerRadius)
    }
}
