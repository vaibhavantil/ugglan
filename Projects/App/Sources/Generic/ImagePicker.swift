import Flow
import Foundation
import MobileCoreServices
import Photos
import Presentation
import UIKit

struct ImagePicker {
	let sourceType: UIImagePickerController.SourceType
	let mediaTypes: Set<MediaType>

	enum MediaType { case video, photo }
}

private var didPickImageCallbackerKey = 0
private var didCancelImagePickerCallbackerKey = 1

extension UIImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	private var didPickImageCallbacker: Callbacker<Either<PHAsset, UIImage>> {
		if let callbacker = objc_getAssociatedObject(self, &didPickImageCallbackerKey)
			as? Callbacker<Either<PHAsset, UIImage>> {
			return callbacker
		}

		delegate = self

		let callbacker = Callbacker<Either<PHAsset, UIImage>>()

		objc_setAssociatedObject(
			self,
			&didPickImageCallbackerKey,
			callbacker,
			.OBJC_ASSOCIATION_RETAIN_NONATOMIC
		)

		return callbacker
	}

	private var didCancelImagePickerCallbacker: Callbacker<Void> {
		if let callbacker = objc_getAssociatedObject(self, &didCancelImagePickerCallbackerKey)
			as? Callbacker<Void> {
			return callbacker
		}

		delegate = self

		let callbacker = Callbacker<Void>()

		objc_setAssociatedObject(
			self,
			&didCancelImagePickerCallbackerKey,
			callbacker,
			.OBJC_ASSOCIATION_RETAIN_NONATOMIC
		)

		return callbacker
	}

	var didPickImageSignal: Signal<Either<PHAsset, UIImage>> { didPickImageCallbacker.providedSignal }

	var didCancelSignal: Signal<Void> { didCancelImagePickerCallbacker.providedSignal }

	public func imagePickerControllerDidCancel(_: UIImagePickerController) {
		didCancelImagePickerCallbacker.callAll()
	}

	public func imagePickerController(
		_: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
	) {
		guard let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else {
			if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
				didPickImageCallbacker.callAll(with: .make(originalImage))
			}

			return
		}

		didPickImageCallbacker.callAll(with: .make(asset))
	}
}

enum ImagePickerError: Error { case cancelled }

extension ImagePicker: Presentable {
	func materialize() -> (UIImagePickerController, Future<Either<PHAsset, UIImage>>) {
		let viewController = UIImagePickerController()

		if UIImagePickerController.isSourceTypeAvailable(sourceType) {
			viewController.sourceType = sourceType
		} else {
			viewController.sourceType = .photoLibrary
		}

		viewController.preferredPresentationStyle = .modally(
			presentationStyle: .pageSheet,
			transitionStyle: nil,
			capturesStatusBarAppearance: nil
		)

		viewController.mediaTypes = mediaTypes.map { type -> String in
			switch type {
			case .photo: return kUTTypeImage as String
			case .video: return kUTTypeMovie as String
			}
		}

		return (
			viewController,
			Future { completion in let bag = DisposeBag()

				bag += viewController.didPickImageSignal.onValue { result in
					completion(.success(result))
				}

				bag += viewController.didCancelSignal.onValue { _ in
					completion(.failure(ImagePickerError.cancelled))
				}

				return bag
			}
		)
	}
}
