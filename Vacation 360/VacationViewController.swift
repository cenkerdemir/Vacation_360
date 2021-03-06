/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class VacationViewController: UIViewController {
    
    @IBOutlet weak var imageVRView: GVRPanoramaView!
    @IBOutlet weak var videoVRView: GVRVideoView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var videoLabel: UILabel!
    
    enum Media {
        static var photoArray = ["sindhu_beach.jpg", "grand_canyon.jpg", "underwater.jpg"]
        static let videoURL = "https://s3.amazonaws.com/ray.wenderlich/elephant_safari.mp4"
    }
    
    var currentView : UIView?
    var currentDisplayMode = GVRWidgetDisplayMode.embedded
    
    var isPaused = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageVRView.load(UIImage.init(named: Media.photoArray.first!), of: GVRPanoramaImageType.mono)
        self.videoVRView.load(from: URL.init(string: Media.videoURL))
        
        self.imageVRView.enableCardboardButton = true
        self.imageVRView.enableFullscreenButton = true
        
        self.videoVRView.enableCardboardButton = true
        self.videoVRView.enableFullscreenButton = true
        
        // hide the labels and VRViews, so we can unhide them once the content is loaded successfully. Plus, add the delegates
        imageLabel.isHidden = true
        imageVRView.isHidden = true
        imageVRView.delegate = self
        
        videoLabel.isHidden = true
        videoVRView.isHidden = true
        videoVRView.delegate = self
    }
    
    func refreshVideoStatus() {
        if currentView == videoVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
            videoVRView.resume()
            isPaused = false
        }
        else {
            videoVRView.pause()
            isPaused = true
        }
    }
    
}

// extension for the widget view delegate
extension VacationViewController : GVRWidgetViewDelegate {
    
    func widgetView(_ widgetView: GVRWidgetView!, didLoadContent content: Any!) {
        if content is UIImage {
            imageLabel.isHidden = false
            imageVRView.isHidden = false
        }
        else if content is NSURL {
            videoLabel.isHidden = false
            videoVRView.isHidden = false
            refreshVideoStatus()
        }
        
    }
    
    func widgetView(_ widgetView: GVRWidgetView!, didFailToLoadContent content: Any!, withErrorMessage errorMessage: String!) {
        print(errorMessage)
    }
    
    func widgetView(_ widgetView: GVRWidgetView!, didChange displayMode: GVRWidgetDisplayMode) {
        currentView = widgetView
        currentDisplayMode = displayMode
        refreshVideoStatus()
        if currentView == imageVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
            view.isHidden = true
        }
        else {
            view.isHidden = false
        }
    }
    
    func widgetViewDidTap(_ widgetView: GVRWidgetView!) {
        guard currentDisplayMode != GVRWidgetDisplayMode.embedded else {return}
        
        if currentView == imageVRView {
            Media.photoArray.append(Media.photoArray.removeFirst())
            imageVRView.load(UIImage(named:Media.photoArray.first!), of: GVRPanoramaImageType.mono)
        }
        else {
            if isPaused == true {
                videoVRView.resume()
            }
            else {
                videoVRView.pause()
            }
            isPaused = !isPaused
        }
    }
}

// extension for the video view delegate
extension VacationViewController : GVRVideoViewDelegate {
    func videoView(_ videoView: GVRVideoView!, didUpdatePosition position: TimeInterval) {
        if position >= videoView.duration() {
            videoView.seek(to: 0)
            videoView.resume()
        }
    }
}


