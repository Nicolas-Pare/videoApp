//
//  videoViewController.swift
//  VideoApp
//
//  Created by Nicolas Paré on 18-08-11.
//  Copyright © 2018 Nicolas Paré. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI
import SDRecordButton
import Photos
//import SSZipArchive

class videoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var camPreview: UIView!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureMovieFileOutput()
    let cameraButton = UIView()
    let email = "nicolaspare313@gmail.com"
    
    var progressTimer = Timer()
    var progress: Float = 0.0
    let videoDuration: Float = 3
    
    @IBOutlet weak var backgroundConfUI: UIImageView!
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var removableImage: UIImageView!
    @IBOutlet weak var removableLabel: UILabel!
    var isRecording = false
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice:AVCaptureDevice! = nil
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var Currentorientation = AVCaptureVideoOrientation.portrait
    //var zipURL: String?
    
    
    @IBOutlet weak var recordButton: SDRecordButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //let captureDevice = AVCaptureDevice.default(for: .video)
        // Do any additional setup after loading the view.
        checkOrientation()
        prepareCamera()
        cameraButton.isUserInteractionEnabled = true
        //let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoViewController.startCapture))
        
        let recordBtnfirstTouch = UITapGestureRecognizer(target: self, action: #selector(videoViewController.recording))
        
        /* check this for action reference for exemple project
        [self.recordButton addTarget:self action:@selector(recording) forControlEvents:UIControlEventTouchDown];
        [self.recordButton addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpOutside];
        */
        //cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        
        cameraButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cameraButton.backgroundColor = UIColor.red
        
        recordButton.addGestureRecognizer(recordBtnfirstTouch)
        
        //recordButton.frame = CGRect(x: recordButton.frame.origin.x, y: recordButton.frame.origin.y, width: 100, height: 100)
        //recordButton.
        backgroundConfUI.isHidden = true
        restartBtn.isHidden = true
        sendBtn.isHidden = true
        
        camPreview.addSubview(recordButton)
        camPreview.addSubview(removableLabel)
        camPreview.addSubview(removableImage)
    }
    
    
    func checkOrientation(){
        Currentorientation = currentVideoOrientation()
    }
    
    @objc func recording() {
        print("entering recording")
        if(self.isRecording == false){
            startCapture()
            removableLabel.alpha = 0
            print("start recording(pass if statment)")
            self.progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            isRecording = true
        }else{
            endRecording()
        }
    }
    func endRecording() {
        print("entering endRecording")
        print(self.isRecording)
        if(self.isRecording == true){
            print("stop recording(pass if statment)")
            self.progressTimer.invalidate()
            self.progress = 0.0
            isRecording = false
            startCapture()
        }
    }
    @objc func updateProgress() {
        //print("updateProgress")
        self.progress += 0.05/videoDuration
        //print(self.progress)
        self.recordButton.setProgress(CGFloat(self.progress))
        if(self.progress >= 1){
            print("time up!")
            print(self.progress)
            endRecording()
        }
    }
    
    func setupConfirmation() {
        
        print("setupConfirmation")
        camPreview.addSubview(backgroundConfUI)
        camPreview.addSubview(restartBtn)
        camPreview.addSubview(sendBtn)
    
        backgroundConfUI.isHidden = false
        restartBtn.isHidden = false
        sendBtn.isHidden = false
    }
    @IBAction func saveVideo(_ sender: Any) {
        print("in save video -------&")
        print(outputURL)
        let output = outputURL as URL
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: output)
        }) { saved, error in
            if saved {
                //let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                //let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                //alertController.addAction(defaultAction)
                //self.present(alertController, animated: true, completion: nil)
                
            }
        }
        outputURL = nil
        performSegue(withIdentifier: "videoToThanks", sender: nil)
    }
    
    @IBAction func restartCapture(_ sender: Any) {
        outputURL = nil
        performSegue(withIdentifier: "backToPermission", sender: nil)
    }
    
    
    //func secondFileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?)
    
    
    func prepareCamera(){
        print("prepareCamera")
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInMicrophone], mediaType: AVMediaType.video, position: .front).devices
        if availableDevices.first != nil {
            captureDevice = availableDevices.first
            if beginSession() {
                startSession()
            }
        }
        
    }
    
    func beginSession() -> Bool {
        print("beginSession")
        //setup the camera input
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
                activeInput = captureDeviceInput
            }
        }catch {
            print(error.localizedDescription)
        }
        
        //setup the microphone input
        let microphone = AVCaptureDevice.default(for: .audio)
        
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.bounds
        let theOrientation = currentVideoOrientation()
        print(theOrientation)
        //previewLayer.connection?.videoOrientation = theOrientation
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
        //captureSession.startRunning()
        
        //let dataOutput = AVCaptureVideoDataOutput()
        //dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
        
        //dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(videoOutput){
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        print("start session")
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        print("stopSession")
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
        
    }
    
    func videoQueue() -> DispatchQueue {
        
        return DispatchQueue.main
    }
    
    @objc func currentVideoOrientation() -> AVCaptureVideoOrientation{
        
        print("current video orientation")
        var orientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            print("not supported portrait")
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            print("landscape right")
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            print("not supported portrait upside down")
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft:
            print("landscape left")
            orientation = AVCaptureVideoOrientation.landscapeLeft
        default:
            print("default?")
            orientation = Currentorientation
        }
        return orientation
    }
    
    @objc func startCapture() {
        print("startCapture")
        startRecording()
        
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        print("temp URL generated")
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mov")
            print(path)
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    /*func tempZipPath() -> String {
        print("temp URL generated")
        let directory = NSTemporaryDirectory() as NSString
     
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".zip")
            print(path)
            return path
        }
     
        return ""
    }*/
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        let connection = videoOutput.connection(with: AVMediaType.video)
        previewLayer.connection?.videoOrientation = orientation
        connection?.videoOrientation = orientation
        self.Currentorientation = orientation
        previewLayer.frame = self.view.bounds
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("override viewDidLayoutSubviews")
        if let connection =  self.previewLayer?.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                print("supported")
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: AVCaptureVideoOrientation.portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: AVCaptureVideoOrientation.landscapeLeft)
                    print("right")
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: AVCaptureVideoOrientation.landscapeRight)
                    print("left")
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: AVCaptureVideoOrientation.portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: AVCaptureVideoOrientation.landscapeLeft)
                    print("and yet default")
                    break
                }
            }
        }
    }
    
    func startRecording() {
        print("start recording")
        
        if videoOutput.isRecording == false {
            print("pass if statment for start recording")
            let connection = videoOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)! {
                print("orientation befor record --------;")
                print(currentVideoOrientation())
                //connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        }
        else {
            print("call stop recording")
            stopRecording()
            //sendEmail()
        }
        
    }
    
    func stopRecording() {
        print("enter stopRcording")
        if videoOutput.isRecording == true {
            print("enter if and call stop methode")
            videoOutput.stopRecording()
        }
    }
    /*func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
     print("didFinishRecording?")
     sendEmail()
     }*/
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("didStartRecordingToOutputFileAt")
    }
    
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("didFinishRecordingToOutputFileAt")
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            print("capture output as url")
            print("before end of file output -----+")
            print(outputURL)
            _ = outputURL as URL
            //sendEmail()
            
            setupConfirmation()
            /*if error == nil {
                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            }*/
        }
    }
    /*func saveVideoToFile(){
        print("save to documentDirectory")
        let fileMngr = FileManager.default;
        let paths = fileMngr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let stringPaths = paths.path
        let fileUrl = paths.appendingPathComponent("output.mov")
        try? FileManager.default.removeItem(at: fileUrl)
        videoOutput.startRecording(to: fileUrl, recordingDelegate: self)
        /*let delayTime = dispatch_time(dispatch_time_t, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("stopping")
            self.videoOutput.stopRecording()
        }*/
    }*/
    
    func sendEmail(){
        if( MFMailComposeViewController.canSendMail()){
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set to recipients
            mailComposer.setToRecipients([email])
            
            //Set the subject
            mailComposer.setSubject("email with video message")
            
            //set mail body
            mailComposer.setMessageBody("This is what they sound like.", isHTML: true)
            
            print("File data loaded.")
            //let videoData = NSData(contentsOfURL: outputURL!, options: nil, error: nil)
            do {
                let videoData = try Data(contentsOf: outputURL as URL)
                mailComposer.addAttachmentData(videoData, mimeType: "mov", fileName: "commentaire.mov")
            } catch {
                print("Unable to load data: \(error)")
            }
            
            //this will compose and present mail to user
            self.present(mailComposer, animated: true, completion: nil)
        }
        else
        {
            print("email is not supported")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("mailComposeController")
        controller.dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "backToPermission", sender: nil)
        self.performSegue(withIdentifier:"videoToThanks", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
