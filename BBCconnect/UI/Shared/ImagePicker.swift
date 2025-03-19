//
//  ImagePicker.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import UIKit

public struct ImagePicker: UIViewControllerRepresentable {
	
	@Environment(\.presentationMode) private var presentationMode
	
	@Binding private var selectedImage: UIImage
	private var sourceType: UIImagePickerController.SourceType = .photoLibrary
	private var compressionSize: (height: CGFloat, width: CGFloat) = (400, 400)
	private var onImageDataAvailable: ((Data?) -> Void)?
	
	public init(sourceType: UIImagePickerController.SourceType = .photoLibrary, selectedImage: Binding<UIImage>, compressionSize: (CGFloat, CGFloat) = (400, 400), onImageDataAvailable: ((Data?) -> Void)? = nil) {
		self.sourceType = sourceType
		self._selectedImage = selectedImage
		self.compressionSize = compressionSize
		self.onImageDataAvailable = onImageDataAvailable
	}
	
	public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
		let imagePicker = UIImagePickerController()
		imagePicker.allowsEditing = false
		imagePicker.sourceType = self.sourceType
		imagePicker.delegate = context.coordinator
		return imagePicker
	}
 
	public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
 
	}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
		var parent: ImagePicker
  
		public init(_ parent: ImagePicker) {
			self.parent = parent
		}
  
		public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
  
			if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
				if let compressedImage = image.scaleAndRotate(maxHeight: self.parent.compressionSize.height, maxWidth: self.parent.compressionSize.width) {
					self.parent.selectedImage = compressedImage
				}
				else {
					self.parent.selectedImage = image
				}
				
				if let onImageDataAvailable = parent.onImageDataAvailable,
					let data = image.jpegData(compressionQuality: 1.0) {
					onImageDataAvailable(data)
				}
			}
  
			self.parent.presentationMode.wrappedValue.dismiss()
		}
		
		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			if let onImageDataAvailable = self.parent.onImageDataAvailable {
				onImageDataAvailable(nil)
			}
			
			self.parent.presentationMode.wrappedValue.dismiss()
		}
	}
}

fileprivate extension UIImage {
	func scaleAndRotate(maxHeight: CGFloat, maxWidth: CGFloat) -> UIImage? {
		guard let imgRef = self.cgImage else { return nil }
		
		let width = CGFloat(imgRef.width)
		let height = CGFloat(imgRef.height)
		
		var bounds = CGRect(x: 0, y: 0, width: width, height: height)
		
		if height > maxHeight, width <= maxWidth {
			bounds.size.height = maxHeight
			bounds.size.width = bounds.size.height * (width / height)
		} else if width > maxWidth {
			bounds.size.width = maxWidth
			bounds.size.height = bounds.size.width * (height / width)
		} else if height > maxHeight, width > maxWidth {
			if (height - maxHeight) > (width - maxWidth) {
				bounds.size.height = maxHeight
				bounds.size.width = bounds.size.height * (width / height)
			} else {
				bounds.size.width = maxWidth
				bounds.size.height = bounds.size.width * (height / width)
			}
		}
		
		let scaleRatio = bounds.size.width / width
		let imageSize = CGSize(width: imgRef.width, height: imgRef.height)
		var transform = CGAffineTransform.identity
		let orientation = self.imageOrientation
		
		switch orientation {
		case .up:
			transform = .identity
		case .upMirrored:
			transform = CGAffineTransform(translationX: imageSize.width, y: 0).scaledBy(x: -1, y: 1)
		case .down:
			transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height).rotated(by: .pi)
		case .downMirrored:
			transform = CGAffineTransform(translationX: 0, y: imageSize.height).scaledBy(x: 1, y: -1)
		case .leftMirrored:
			bounds.size = CGSize(width: bounds.height, height: bounds.width)
			transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
				.scaledBy(x: -1, y: 1)
				.rotated(by: 3 * .pi / 2)
		case .left:
			bounds.size = CGSize(width: bounds.height, height: bounds.width)
			transform = CGAffineTransform(translationX: 0, y: imageSize.width).rotated(by: 3 * .pi / 2)
		case .rightMirrored:
			bounds.size = CGSize(width: bounds.height, height: bounds.width)
			transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2)
		case .right:
			bounds.size = CGSize(width: bounds.height, height: bounds.width)
			transform = CGAffineTransform(translationX: imageSize.height, y: 0).rotated(by: .pi / 2)
		@unknown default:
			return nil
		}
		
		UIGraphicsBeginImageContext(bounds.size)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		
		if orientation == .right || orientation == .left {
			context.scaleBy(x: -scaleRatio, y: scaleRatio)
			context.translateBy(x: -height, y: 0)
		} else {
			context.scaleBy(x: scaleRatio, y: -scaleRatio)
			context.translateBy(x: 0, y: -height)
		}
		
		context.concatenate(transform)
		context.draw(imgRef, in: CGRect(x: 0, y: 0, width: width, height: height))
		
		let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return imageCopy
	}
}
