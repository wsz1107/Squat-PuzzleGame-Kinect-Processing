import KinectPV2.KJoint;
import KinectPV2.*;
import java.util.LinkedList;
import ddf.minim.*;

//BGM, SE
Minim minim;
AudioPlayer bgm, seStart, seFinish;

//パズルゲーム
PImage imgEasy, imgHard, imgGame;
LinkedList<Integer> book = new LinkedList<Integer>();
int difficultyLevel;
int total;
int gameControllerFlag;
float timeLimit;
float startTime;

//キネクト
KinectPV2 kinect;
float zVal = 300;
float rotX = PI;
int squat = 0;
int squatPoseMode = 0;
int countSquatFlag = 0;
float heightOfHipLeft=0, heightOfHipRight=0;
float heightOfFootLeft = 0, heightOfFootRight = 0;
float heightOfKneeLeft = 0, heightOfKneeRight = 0;

//UI
float imageWidth, imageHeight;
float imageX, imageY;

void setup() {
  size(890, 720, P3D);
  //パズルゲーム
  imgEasy = loadImage("Koala.jpg");
  imgHard = loadImage("MonaLisa.jpg");

  difficultyLevel=2;
  total=(int)sq(difficultyLevel);
  timeLimit = 99.0;

  gameControllerFlag = 0;

  //キネクト
  kinect = new KinectPV2(this);
  kinect.enableColorImg(true);
  //enable 3d  with (x,y,z) position
  kinect.enableSkeleton3DMap(true);
  kinect.init();

  //BGM, SE
  minim = new Minim(this);
  bgm = minim.loadFile("MusMus-BGM-083.mp3");
  seStart = minim.loadFile("start.mp3");
  seFinish = minim.loadFile("finish.mp3");
  bgm.play();

  //UI
  imageWidth = 576;
  imageHeight = 720;
  imageX = 320;
  imageY = 0;
}

void draw() {
  background(255);

  image(kinect.getColorImage(), 0, 0, 320, 240);

  if (gameControllerFlag == 0) {
    textSize(32);
    textAlign(CENTER);
    fill(0);
    text("Press E to \nEasy Mode\nPress H to \nHard Mode", 160, 360);
  }
  if (gameControllerFlag == 1) {
    //translate the scene to the center 
    pushMatrix();
    translate(width/2, height/2, 0);
    scale(zVal);
    rotateX(rotX);

    ArrayList<KSkeleton> skeletonArray =  kinect.getSkeleton3d();

    //individual JOINTS
    for (int i = 0; i < skeletonArray.size(); i++) {
      KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
      if (skeleton.isTracked()) {
        KJoint[] joints = skeleton.getJoints();

        heightOfHipLeft = joints[12].getY()*1000;
        heightOfHipRight = joints[16].getY()*1000;
        heightOfFootLeft = joints[15].getY()*1000;
        heightOfFootRight = joints[19].getY()*1000;
        heightOfKneeLeft = joints[13].getY()*1000;
        heightOfKneeRight = joints[17].getY()*1000;
      }
    }
    popMatrix();

    checkSquat();

    fill(255, 0, 0);
    textSize(32);
    text(frameRate, 50, 50);
    fill(0, 0, 255);
    textSize(60);
    text("Total", 160, 400);
    text(squat, 160, 470);
    println("total: ", squat);

    pushMatrix();
    translate(imageX, imageY);
    image(imgGame, 0, 0, imageWidth, imageHeight);
    coverTiles();
    popMatrix();

    gameResult();
  }
}

void checkSquat() {
  if (((heightOfKneeLeft - heightOfFootLeft) + (heightOfKneeRight - heightOfFootRight))/2 <= ((heightOfHipLeft - heightOfFootLeft) + (heightOfHipRight - heightOfFootRight))/2) {
    squatPoseMode = 0;
    if (countSquatFlag == 1) {
      if (gameControllerFlag == 1) {
        int n= (int)random(total-1);
        if (total != 0) {
          book.remove(n);
          total--;
        }
      }
      squat ++;
    }
    countSquatFlag = 0;
  } else {
    squatPoseMode = 1;
    countSquatFlag = 1;
  }
}

void keyPressed() {
  if ((key == 'e' || key == 'E') && gameControllerFlag == 0) {
    gameControllerFlag = 1;
    difficultyLevel = 3;
    total=(int)sq(difficultyLevel);
    for (int i=0; i<total; i++) {
      book.add(i);
    }
    imgGame = imgEasy;
    timeLimit = 12.0;
    startTime = millis()*0.001;
    seStart.play();
  }
  if ((key == 'h' || key == 'H') && gameControllerFlag == 0) {
    gameControllerFlag = 1;
    difficultyLevel = 4;
    total=(int)sq(difficultyLevel);
    for (int i=0; i<total; i++) {
      book.add(i);
    }
    imgGame = imgHard;
    timeLimit = 20.0;
    startTime = millis()*0.001;
    seStart.play();
  }
}

void coverTiles() {
  noStroke();
  fill(255);
  for (int i=0; i<total; i++) {
    if (gameControllerFlag == 1) {
      for (int j=0; j<(int)sq(difficultyLevel); j++) {
        if (book.get(i) == j) {
          rect(floor(j/difficultyLevel)*imageWidth/difficultyLevel, floor(j%difficultyLevel)*imageHeight/difficultyLevel, imageWidth/difficultyLevel, imageHeight/difficultyLevel);
        }
      }
    }
  }
}

void gameResult() {
  if (total == 0) {
    fill(0, 255, 0);
    textSize(40);
    text("Congratulations!", 160, 660);
    seFinish.play();
    noLoop();
  }
  if (timeLimit+startTime-millis()*0.001 >= 0) {
    fill(0, 0, 255);
    textSize(56);
    text("Countdown", 160, 540);
    textSize(40);
    text(timeLimit+startTime-millis()*0.001, 160, 600);
  } else if (total > 0) {
    fill(255, 0, 0);
    textSize(40);
    text("Time is out!", 160, 600);
    bgm.pause();
    seFinish.play();
    noLoop();
  }
}
