import Foundation

func getScaledSize(for size: CGSize, withMaxSize maxSize: CGFloat) -> CGSize {
    let aspectRatio = size.width / size.height

    return aspectRatio > 1
        ? CGSize(width: maxSize, height: maxSize / aspectRatio)
        : CGSize(width: maxSize * aspectRatio, height: maxSize)
}
