import gab.opencv.*;
import java.awt.Rectangle;
import websockets.*;
//import KinectPV2.KJoint;
import KinectPV2.*;

WebsocketServer ws;
OpenCV opencv;
KinectPV2 kinect;

int now;

//Ermittelte XY Koordinaten
float PersonX = 1; 
float PersonY = 1;

//Pixelmasse > größer als
float Pixelgroesse = 50;
// Pixelmasse in Gesamtmasse der Pixelumwandeln

//Angepasse XY Koordinaten
float PersonXSkaliert;
float PersonYSkaliert;

//PixelgrößeBeamer
int Projektionsbreite = 1920;     //Beamer MAK 1920
int Projektionshoehe = 1200;      //Beamer MAK 1200

//KinectTracking
int Trackingbreite = 512;   //Kamerabild
int Trackinghoehe = 424;    //Kamerabild

//Verschiebung der X-Koordinaten
float Pixelverschiebung; 
float Verhaeltnis;
float PersonXSkaliertVerschoben;

//Distance Threashold
int maximaleDistanz = 1050; // 4500 max 4.5mx
int minimaleDistanz = 5;  //  50cm

PImage RechtsTiefenbild;
PImage LinksTiefenbild;
PImage LinksTiefenbildGespiegelt; 
PImage RechtsTiefenbildGespiegelt;

void setup() {
  size(1024, 424, P3D);
  opencv = new OpenCV( this, 512, 424);
  kinect = new KinectPV2(this);

  //Enable point cloud
  kinect.enableDepthImg(true);
  kinect.enablePointCloud(true);
  kinect.init();


  now=millis();
  ws = new WebsocketServer(this, 8123, "/kinect_position");
}

void draw() {
  background(0);

  //RechtsTiefenbild =  kinect.getDepthImage();
  //image(RechtsTiefenbild, 512, 424);


  // Gespiegeltes Tiefenbild Rechts 
  pushMatrix();
  RechtsTiefenbildGespiegelt = kinect.getDepthImage();
  scale(-1, 1); 
  image(RechtsTiefenbildGespiegelt, - RechtsTiefenbildGespiegelt.width - Trackingbreite, 0);
  popMatrix();

  int [] rawData = kinect.getRawDepthData();


  //Threshold Distanz Tiefe
  kinect.setLowThresholdPC(minimaleDistanz);
  kinect.setHighThresholdPC(maximaleDistanz);

  //minimaleDistanz = map(mouseX, 0, width, 0, 4500);
  //maximaleDistanz = map(mouseY, 0, height, 0, 4500);
  // Gespiegeltes Tiefenbild Links

  LinksTiefenbild = kinect.getPointCloudDepthImage();
  opencv.loadImage(LinksTiefenbild);
  opencv.flip(opencv.HORIZONTAL);
  opencv.getOutput();


  // Konturen Zeichnen 
  ArrayList<Contour> contours = opencv.findContours();
  ArrayList<Float> personXSkaliertVerschobenList = new ArrayList();
  ArrayList<Float> personYSkaliertList = new ArrayList();
  for (Contour contour : contours) {
    stroke(0, 0, 255);
    contour.draw();   

    // Mittelpunkt berechnen
    Rectangle Person = contour.getBoundingBox();
    float PersonX = (int)Person.getX() + (int)(Person.getWidth() / 2.0);
    float PersonY = (int)Person.getY() + (int)(Person.getHeight() / 2.0); 

    // Skalierung der Pixel zur Größe der Projektionsfläche
    PersonXSkaliert = PersonX *(Projektionsbreite/Trackingbreite);
    PersonYSkaliert = PersonY *(Projektionshoehe/ Trackingbreite);

    Verhaeltnis = (Projektionsbreite/Trackingbreite);
    Pixelverschiebung = ((Projektionsbreite - (Trackingbreite * Verhaeltnis))/2);
    PersonXSkaliertVerschoben = (PersonXSkaliert + Pixelverschiebung);

    int i=0;
    //Wenn Pixelmasse zu gering, Senden der XY Daten aussetzen 
    if (Person.width > Pixelgroesse) {
      personXSkaliertVerschobenList.add(PersonXSkaliertVerschoben);
      personYSkaliertList.add(PersonYSkaliert);
      circle(PersonX, PersonY, Pixelgroesse);
    } else if (Person.height > Pixelgroesse) {
      personXSkaliertVerschobenList.add(PersonXSkaliertVerschoben);
      personYSkaliertList.add(PersonYSkaliert);
      circle(PersonX, PersonY, Pixelgroesse);
    }

    //Server
    if (millis()>now+20) { 
      now=millis();
    }
    i+=1;
  }
  String message = "0"; // <- not important, just for the current protocol to work
  for (int i=0; i<personXSkaliertVerschobenList.size(); i++) {
    message += "," + str(personXSkaliertVerschobenList.get(i));
    message += "," + str(personYSkaliertList.get(i));
  }
  ws.sendMessage(message);   
}


void keyPressed() {

  if (key == '1') {
    minimaleDistanz += 100;
    println("Change min: "+minimaleDistanz);
  }

  if (key == '2') {
    minimaleDistanz -= 100;
    println("Change min: "+minimaleDistanz);
  }

  if (key == '3') {
    maximaleDistanz += 100;
    println("Change max: "+maximaleDistanz);
  }

  if (key == '4') {
    maximaleDistanz -=100;
    println("Change max: "+maximaleDistanz);
  }

  if (key == 'a') {
    Pixelgroesse +=10;
    println("Change max: "+maximaleDistanz);
  }
  if (key == 's') {
    Pixelgroesse -=10;
    println("Change max: "+maximaleDistanz);
  }
}
