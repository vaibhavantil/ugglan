import Apollo
import CoreML
import Disk
import Flow
import Foundation
import hCore
import hGraphQL
import UIKit
import Vision

extension AddKeyGearItem {
	private enum Category: String {
		case smartWatch = "SmartWatches"
		case watch = "Watches"
		case appliance = "Applicances"
		case camera = "Camera"
		case jewelry = "Jewelry"
		case phone = "Phones"
		case bicycle = "Bicycle"
		case computer = "Computer"
	}

	func classifyImage(_ image: UIImage) -> Future<GraphQL.KeyGearItemCategory?> {
		Future { completion in let bag = DisposeBag()

			bag += VNCoreMLModel.keyGearClassifier.onValue { model in
				let delegate = Delegate<Either<VNRequest, Error>, Void>()
				let request = VNCoreMLRequest(model: model, delegate: delegate)

				bag += delegate.set { result in
					let classifications = result.left?.results as! [VNClassificationObservation]
					if let classification = classifications.first {
						if classification.confidence > 0.9 {
							guard
								let category = Category(
									rawValue: classification.identifier
								)
							else {
								completion(.success(nil))
								return
							}

							switch category {
							case .smartWatch:
								completion(
									.success(GraphQL.KeyGearItemCategory.smartWatch)
								)
							case .watch:
								completion(
									.success(GraphQL.KeyGearItemCategory.jewelry)
								)
							case .appliance: completion(.success(nil))
							case .camera: completion(.success(nil))
							case .phone:
								completion(.success(GraphQL.KeyGearItemCategory.phone))
							case .bicycle:
								completion(.success(GraphQL.KeyGearItemCategory.bike))
							case .computer:
								completion(
									.success(GraphQL.KeyGearItemCategory.computer)
								)
							case .jewelry:
								completion(
									.success(GraphQL.KeyGearItemCategory.jewelry)
								)
							}
						} else {
							completion(.success(nil))
						}
					}
				}

				request.imageCropAndScaleOption = .centerCrop

				func process(request: VNCoreMLRequest, image: UIImage) {
					guard let ciImage = CIImage(image: image) else { return }

					DispatchQueue.global(qos: .userInitiated)
						.async {
							let handler = VNImageRequestHandler(
								ciImage: ciImage,
								orientation: .up
							)
							try? handler.perform([request])
						}
				}

				process(request: request, image: image)
			}

			return bag
		}
	}
}

extension VNCoreMLModel {
	enum KeyGearClassifierError: Error { case compileModel, convertModel, downloadModel, createVNModel }

	static var keyGearClassifier: Future<VNCoreMLModel> {
		let client: ApolloClient = Dependencies.shared.resolve()
		let bag = DisposeBag()

		return Future { completion in let cacheFileName = "key-gear-classifier.mlmodelc"

			func createModel(_ url: URL) {
				guard let model = try? MLModel(contentsOf: url) else {
					completion(.failure(KeyGearClassifierError.convertModel))
					return
				}

				guard let vnModel = try? VNCoreMLModel(for: model) else {
					completion(.failure(KeyGearClassifierError.createVNModel))
					return
				}

				completion(.success(vnModel))
			}

			func downloadModel(_ url: URL) {
				let task = URLSession.shared.downloadTask(with: url) { location, _, _ in
					guard let location = location else {
						completion(.failure(KeyGearClassifierError.downloadModel))
						return
					}

					guard let compiledUrl = try? MLModel.compileModel(at: location) else {
						completion(.failure(KeyGearClassifierError.compileModel))
						return
					}

					if let cacheUrl = try? Disk.url(for: cacheFileName, in: .caches) {
						try? Disk.move(compiledUrl, to: cacheUrl)
						createModel(cacheUrl)
					} else {
						createModel(compiledUrl)
					}
				}

				task.resume()
			}

			func getCacheURL() -> URL? {
				let isCached = Disk.exists(cacheFileName, in: .caches)

				if !isCached { return nil }

				return try? Disk.url(for: cacheFileName, in: .caches)
			}

			if let cachedUrl = getCacheURL() {
				createModel(cachedUrl)
				return bag
			}

			bag += client.fetch(query: GraphQL.KeyGearClassifierQuery())
				.map { data in data.coreMlModels.first?.file?.url }.valueSignal
				.compactMap { url in URL(string: url) }.onValue { url in downloadModel(url) }

			return bag
		}
	}
}

extension VNCoreMLRequest {
	convenience init(
		model: VNCoreMLModel,
		delegate: Delegate<Either<VNRequest, Error>, Void>
	) {
		self.init(model: model) { request, error in
			guard let error = error else {
				delegate.call(.left(request))
				return
			}

			delegate.call(.right(error))
		}
	}
}
