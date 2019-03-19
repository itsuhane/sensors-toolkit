import UIKit
import AVFoundation
import CoreMedia
import VideoToolbox

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var cameraImageView: UIView!
    @IBOutlet weak var outputSwitch: UISegmentedControl!
    @IBOutlet weak var outputTextField: UITextField!
    @IBOutlet weak var captureSwitch: UISwitch!
    @IBOutlet weak var footerAreaMargin: NSLayoutConstraint!
    @IBOutlet weak var focusSlider: UISlider!
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var isoSlider: UISlider!
    @IBOutlet weak var fpsSlider: UISlider!
    @IBOutlet weak var boxingSwitch: UISegmentedControl!
    @IBOutlet weak var autoFocusSwitch: UISwitch!
    @IBOutlet weak var autoExposureSwitch: UISwitch!
    @IBOutlet weak var panelHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        initLocation()
        unlockGUI()
    }

    @objc func applicationDidBecomeActive() {
        unlockGUI()
        startCamera()
    }
    
    @objc func applicationWillResignActive() {
        stopCamera()
        lockGUI()
    }
    
    @IBAction func toggleCapture() {
        if captureSwitch.isOn {
            lockGUI()
            startCapture()
        } else {
            stopCapture()
            unlockGUI()
        }
    }

    @IBAction func toggleOutput() {
    }
    
    @IBAction func toggleBoxing() {
        self.previewLayer?.videoGravity = [.resizeAspect, .resizeAspectFill][boxingSwitch.selectedSegmentIndex]
        App.saveSetting(key: "boxing", value: boxingSwitch.selectedSegmentIndex)
    }
    
    var panelVisible: Bool {
        get {
            return panelHeight.constant > 0
        }
        set (visible) {
            if visible {
                panelHeight.constant = 165
            } else {
                panelHeight.constant = 0
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            App.saveSetting(key: "panel", value: panelVisible)
        }
    }
    
    @IBAction func togglePanel(_ sender: UITapGestureRecognizer) {
        panelVisible = !panelVisible
    }
    
    @IBAction func toggleAutoFocus() {
        focusSlider.isEnabled = !autoFocusSwitch.isOn
        if autoFocusSwitch.isOn {
            camera?.setAutoFocus()
        } else {
            focusChanged()
        }
    }
    
    @IBAction func toggleAutoExposure() {
        exposureSlider.isEnabled = !autoExposureSwitch.isOn
        isoSlider.isEnabled = !autoExposureSwitch.isOn
        if autoExposureSwitch.isOn {
            camera?.setAutoExposure()
        } else {
            exposureChanged()
            isoChanged()
        }
    }
    
    @IBAction func focusChanged() {
        camera?.setFocus(focusSlider.value)
    }
    
    @IBAction func exposureChanged() {
        camera?.setExposure(exposureSlider.value)
    }
    
    @IBAction func isoChanged() {
        camera?.setIso(isoSlider.value)
    }
    
    @IBAction func fpsChanged() {
        let fps = 5.0 * round(fpsSlider.value / 5.0)
        fpsSlider.setValue(fps, animated: true)
        camera?.setFps(fpsSlider.value)
    }
    
    func startCamera() {
        guard let camera = Camera() else {
            NSLog("Cannot access camera")
            return
        }
        
        self.camera = camera
        
        toggleAutoFocus()
        toggleAutoExposure()
        fpsChanged()
        
        let previewLayer = self.camera!.createPreviewLayer()
        self.cameraImageView.layer.sublayers = nil
        self.cameraImageView.layer.addSublayer(previewLayer)
        previewLayer.videoGravity = [.resizeAspect, .resizeAspectFill][boxingSwitch.selectedSegmentIndex]
        previewLayer.frame = self.cameraImageView.frame
        previewLayer.bounds = self.cameraImageView.bounds
        
        self.previewLayer = previewLayer
    }
    
    func stopCamera() {
        if self.output != nil {
            stopCapture()
        }
        self.camera = nil
    }
    
    func initLocation() {
        guard let location = Location() else {
            NSLog("Cannot access location")
            return
        }
        self.location = location
    }
    
    func deinitLocation() {
        self.location = nil
    }
    
    func startCapture() {
        defer {
            captureSwitch.setOn(self.output != nil, animated: true)
            outputTextField.text = self.output?.description
        }
        
        if camera == nil {
            startCamera()
            if camera == nil {
                return
            }
        }
                
        if !location!.start() {
            return
        }

        let motion = Motion()
        
        var output: PipelineOutput?
        if outputSwitch.selectedSegmentIndex == 0 {
            output = FileOutput(name: App.currentDateTimeString)
        } else {
            output = NetworkOutput(address: App.ipv4Address ?? "", port: 5959)
        }
        
        guard
            let outputRef = output,
            let cameraRef = camera,
            let motionRef = motion,
            let locationRef = location,
            let pipeline = Pipeline(camera: cameraRef, motion: motionRef, location: locationRef, output: outputRef, encode: true, saveRawImage: false)
        else {
            return
        }
        
        self.output = output
        self.motion = motion
        self.pipeline = pipeline
        App.keepAwake = true
    }
    
    func stopCapture() {
        App.keepAwake = false
        self.pipeline = nil
        self.motion = nil
        self.output = nil
        captureSwitch.setOn(false, animated: true)
    }
    
    func unlockGUI() {
        panelVisible = App.loadSetting(key: "panel", def: true)
        
        boxingSwitch.selectedSegmentIndex = App.loadSetting(key: "boxing", def: 0)
        
        outputSwitch.selectedSegmentIndex = App.loadSetting(key: "output", def: 0)
        outputSwitch.isEnabled = true
        
        autoFocusSwitch.setOn(App.loadSetting(key: "autofocus", def: true), animated: true)
        autoFocusSwitch.isEnabled = true
        
        autoExposureSwitch.setOn(App.loadSetting(key: "autoexposure", def: true), animated: true)
        autoExposureSwitch.isEnabled = true
        
        focusSlider.setValue(App.loadSetting(key: "focus", def: 0.9), animated: true)
        focusSlider.isEnabled = !autoFocusSwitch.isOn
        
        exposureSlider.setValue(App.loadSetting(key: "exposure", def: 0.1), animated: true)
        exposureSlider.isEnabled = !autoExposureSwitch.isOn
        
        isoSlider.setValue(App.loadSetting(key: "iso", def: 0.3), animated: true)
        isoSlider.isEnabled = !autoExposureSwitch.isOn
        
        fpsSlider.setValue(App.loadSetting(key: "fps", def: 30), animated: true)
        fpsSlider.isEnabled = true
    }
    
    func lockGUI() {
        outputSwitch.isEnabled = false
        autoFocusSwitch.isEnabled = false
        autoExposureSwitch.isEnabled = false
        focusSlider.isEnabled = false
        exposureSlider.isEnabled = false
        isoSlider.isEnabled = false
        fpsSlider.isEnabled = false

        App.saveSetting(key: "panel", value: panelVisible)
        App.saveSetting(key: "boxing", value: boxingSwitch.selectedSegmentIndex)
        App.saveSetting(key: "output", value: outputSwitch.selectedSegmentIndex)
        App.saveSetting(key: "autofocus", value: autoFocusSwitch.isOn)
        App.saveSetting(key: "autoexposure", value: autoExposureSwitch.isOn)
        App.saveSetting(key: "focus", value: focusSlider.value)
        App.saveSetting(key: "exposure", value: exposureSlider.value)
        App.saveSetting(key: "iso", value: isoSlider.value)
        App.saveSetting(key: "fps", value: fpsSlider.value)
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    var camera: Camera? = nil
    var motion: Motion? = nil
    var location: Location? = nil
    var output: PipelineOutput? = nil
    var pipeline: Pipeline? = nil
}
