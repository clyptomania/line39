
import websockets.*;

int ax = 0;
int ay = 300;
int bx = 900;
int by = 700;
int aspeed = 1;
int bspeed = 1;
int now;

WebsocketServer ws;

void setup() {
  size(1080, 1404);
  
  now=millis();
  ws = new WebsocketServer(this, 8123, "/kinect_position");
}

void draw() {
  background(255);

  // Add the current speed to the x location.
  ax = ax + aspeed;

  // Remember, || means "or."
  if ((ax > width) || (ax < 0)) {
    // If the object reaches either edge, multiply speed by -1 to turn it around.
    aspeed = aspeed * -1;
  }
  
  if ((bx > width) || (bx < 0)) {
    bspeed = bspeed * -1;
  }
  
   bx = bx - bspeed;

  // Display circle at x location
  stroke(0);
  fill(175);
  ellipse(ax,ay,32,32);
  ellipse(bx,by,32,32);
  
  int i=0;

  ws.sendMessage(str(i) + "," + str(ax) + "," + str(ay) + "," + str(bx) + "," + str(by));   
  

  
  
  if(millis()>now+20) { 
  now=millis();
    
  }
     i+=1;
  }
   
