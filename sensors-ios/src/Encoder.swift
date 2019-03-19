import VideoToolbox

protocol EncoderDelegate : class {
    func encoderDidOutput(timestamp: CMTime, sampleBuffer: CMSampleBuffer)
    func encoderDidDrop()
}

extension EncoderDelegate {
    func encoderDidDrop() {
    }
}

class Encoder : NSObject {
    weak var delegate: EncoderDelegate? = nil

    init?(width: Int = 640, height: Int = 480, fps: Int = 30) {
        self.fps = fps
        guard let session = VTCompressionSession.create(width: width, height: height, codecType: .H264, outputCallbackRefCon: &callbackRef, outputCallback: {
            outputCallbackRefCon, sourceFrameRefCon, status, infoFlags, sampleBuffer in
            guard let encoder = outputCallbackRefCon?.assumingMemoryBound(to: CallbackRef.self).pointee.encoder else {
                return
            }
            guard let timestampPointer = sourceFrameRefCon?.assumingMemoryBound(to: CMTime.self) else {
                return
            }
            if sampleBuffer != nil {
                encoder.delegate?.encoderDidOutput(timestamp: timestampPointer.pointee, sampleBuffer: sampleBuffer!)
            } else {
                encoder.delegate?.encoderDidDrop()
            }
            timestampPointer.deinitialize(count: 1)
            timestampPointer.deallocate()
        }) else {
            return nil
        }

        let properties = [kVTCompressionPropertyKey_RealTime: kCFBooleanTrue, kVTCompressionPropertyKey_ProfileLevel: kVTProfileLevel_H264_High_5_2, kVTCompressionPropertyKey_AllowFrameReordering: kCFBooleanFalse, kVTCompressionPropertyKey_Quality: NSNumber(value: Float(1.0))] as [String: AnyObject]
        guard session.setProperties(properties) == noErr else {
            return nil
        }

        guard session.prepareToEncodeFrames() == noErr else {
            return nil
        }

        self.session = session

        super.init()

        callbackRef.encoder = self
    }

    deinit {
        session.completeFrames(until: .invalid)
        session.invalidate()
    }

    func encodeFrame(_ timestamp: CMTime, sampleBuffer: CMSampleBuffer) {
        let duration = CMTime(value: 1, timescale: Int32(fps))
        let timestampPointer = UnsafeMutablePointer<CMTime>.allocate(capacity: 1)
        timestampPointer.initialize(to: timestamp)
        guard session.encodeFrame(sampleBuffer.imageBuffer!, presentationTimeStamp: sampleBuffer.presentationTimeStamp, duration: duration, frameProperties: nil, sourceFrameRefcon: timestampPointer, infoFlagsOut: nil) == noErr else {
            NSLog("Cannot encode frame!")
            return
        }
        guard session.completeFrames(until: .invalid) == noErr else {
            NSLog("Cannot complete encoding frames!")
            return
        }
    }

    private let session: VTCompressionSession
    private let fps: Int
    private var callbackRef = CallbackRef()

    private struct CallbackRef {
        weak var encoder: Encoder? = nil
    }
}
