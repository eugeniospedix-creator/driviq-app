import Flutter
import UIKit
import Vision
import CoreImage

@objc class VisionSegmentationPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.driviq/vision_segmentation",
      binaryMessenger: registrar.messenger()
    )
    let instance = VisionSegmentationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "segmentForeground":
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing image path", details: nil))
        return
      }
      segmentForeground(path: path, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func segmentForeground(path: String, result: @escaping FlutterResult) {
    guard let uiImage = UIImage(contentsOfFile: path),
          let cgImage = uiImage.cgImage else {
      result(nil)
      return
    }

    if #available(iOS 17.0, *) {
      let request = VNGenerateForegroundInstanceMaskRequest()
      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      do {
        try handler.perform([request])
        guard let observation = request.results?.first else {
          result(nil)
          return
        }
        let instances = observation.allInstances
        guard !instances.isEmpty else {
          result(nil)
          return
        }
        let maskPixelBuffer = try observation.generateScaledMaskForImage(
          forInstances: instances,
          from: handler
        )
        let ciMask = CIImage(cvPixelBuffer: maskPixelBuffer)
        let context = CIContext(options: nil)
        guard let maskCG = context.createCGImage(ciMask, from: ciMask.extent) else {
          result(nil)
          return
        }

        let width = cgImage.width
        let height = cgImage.height
        var alpha = [UInt8](repeating: 0, count: width * height)

        guard let maskData = maskCG.dataProvider?.data as Data? else {
          result(nil)
          return
        }
        let maskBytes = [UInt8](maskData)
        let maskBpp = max(1, maskBytes.count / max(1, width * height))

        var minX = width
        var minY = height
        var maxX = 0
        var maxY = 0
        var opaqueCount = 0

        for y in 0..<height {
          for x in 0..<width {
            let idx = y * width + x
            let mIdx = idx * maskBpp
            let value = mIdx < maskBytes.count ? maskBytes[mIdx] : 0
            let a: UInt8 = value > 48 ? 255 : 0
            alpha[idx] = a
            if a > 0 {
              opaqueCount += 1
              minX = min(minX, x)
              minY = min(minY, y)
              maxX = max(maxX, x)
              maxY = max(maxY, y)
            }
          }
        }

        if opaqueCount < 64 || maxX <= minX || maxY <= minY {
          result(nil)
          return
        }

        let padX = Double(maxX - minX) * 0.06
        let padY = Double(maxY - minY) * 0.08
        let left = max(0.0, (Double(minX) - padX) / Double(width))
        let top = max(0.0, (Double(minY) - padY) / Double(height))
        let right = min(1.0, (Double(maxX) + padX) / Double(width))
        let bottom = min(1.0, (Double(maxY) + padY) / Double(height))
        let fill = Double(opaqueCount) / Double((maxX - minX + 1) * (maxY - minY + 1))
        let confidence = min(0.96, 0.62 + fill * 0.34)

        result([
          "width": width,
          "height": height,
          "alpha": Data(alpha).base64EncodedString(),
          "left": left,
          "top": top,
          "widthNorm": right - left,
          "heightNorm": bottom - top,
          "confidence": confidence,
        ] as [String: Any])
      } catch {
        result(nil)
      }
      return
    }

    let request = VNGenerateAttentionBasedSaliencyImageRequest()
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
      try handler.perform([request])
      guard let observation = request.results?.first as? VNSaliencyImageObservation,
            let salient = observation.salientObjects?.first else {
        result(nil)
        return
      }
      let box = salient.boundingBox
      result([
        "width": cgImage.width,
        "height": cgImage.height,
        "alpha": Data(repeating: 0, count: cgImage.width * cgImage.height).base64EncodedString(),
        "left": box.origin.x,
        "top": 1.0 - box.origin.y - box.size.height,
        "widthNorm": box.size.width,
        "heightNorm": box.size.height,
        "confidence": 0.58,
      ] as [String: Any])
    } catch {
      result(nil)
    }
  }
}
