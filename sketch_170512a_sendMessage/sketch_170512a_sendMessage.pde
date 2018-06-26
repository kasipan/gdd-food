import gab.opencv.*;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Core.MinMaxLocResult;
import org.opencv.core.Core;
import http.requests.*;

import processing.video.*;
import java.awt.*;

Movie video;
OpenCV inputCV, templateCV;
Mat inputMat, templateMat;
int MessageOpenFlg, rectLocX, rectLocY;
//PFont font;
//PImage messageImg;

void setup() {
  size( 854, 480 );
  
  // target
  video = new Movie(this, "captureMovie.mp4");
  
  inputCV = new OpenCV(this, 854, 480);
  
  // template
  PImage templateImage = loadImage("marker.png");
  templateCV = new OpenCV(this, templateImage);
  templateMat = OpenCV.imitate(templateCV.getGray());
  
  video.loop();
  
  //messageImg = loadImage("message1.png");
  //font = loadFont("YuppySC-Regular-48.vlw");
}


void draw() {
  //scale(0.5);
  inputCV.loadImage(video);
  
  image(video, 0, 0 );
  
  // koko shori
  inputMat = OpenCV.imitate(inputCV.getGray());
  
  int resultCols = inputMat.cols() - templateMat.cols() + 1;
  int resultRows = inputMat.rows() - templateMat.rows() + 1;
  Mat resultMat = new Mat(resultRows, resultCols, CvType.CV_32FC1);

  Imgproc.matchTemplate(inputCV.getColor(), templateCV.getColor(), resultMat, Imgproc.TM_CCOEFF_NORMED);

  MinMaxLocResult mmlr = Core.minMaxLoc(resultMat);
  
  if (mmlr.maxVal > 0.9) {
    //println("Val: " + mmlr.maxVal);
    stroke(255, 0, 0);
    strokeWeight(1);
    noFill();
    rectLocX = (int)mmlr.maxLoc.x;
    rectLocY = (int)mmlr.maxLoc.y;
    rect(rectLocX, rectLocY, templateMat.cols(), templateMat.rows());
    
    // show message
    //textFont(font, 32);
    //text(message, rectLocX, rectLocY);
    //image(messageImg, rectLocX, rectLocY);
    
    if (MessageOpenFlg != 1) {
      sendDemoMessage();
      MessageOpenFlg = 1;
    }
  }

}


void movieEvent(Movie m) {
  m.read();
}



void sendDemoMessage() {
  String messageData = "[{ \"type\": \"text\", \"text\": \"Hi, how are you doing?\"}]";
  
  PostRequest post = new PostRequest("https://api.line.me/v2/bot/message/push");
  //PostRequest post = new PostRequest("https://demo-ee.webscript.io/lineTest");
  post.addHeader("Content-Type", "application/json");
  post.addHeader("Authorization", "Bearer XXXXXXXXX");
  post.addJson(
    "{\"to\":\"XXXXXXX\"," +
    "\"messages\":"+ messageData + 
    "}"
  );
  post.send();
  //println("Reponse Content: " + post.getContent());
}
