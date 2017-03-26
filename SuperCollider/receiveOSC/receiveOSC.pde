// Processing code
PFont font; 
int year; 
int globalyear;


// OSC RECEIVE
import oscP5.*;
import netP5.*;

OscP5 oscP5;                 // objet for OSC send and receive
NetAddress myRemoteLocation;  // objet for service address

void setup() {
  size(600,600);
  pixelDensity(displayDensity());
  oscP5 = new OscP5(this,4859); // start OSC and listen port ...
  // set remote location to localhost SuperColider port
  myRemoteLocation = new NetAddress("127.0.0.1",4859);
  font = createFont ("Courier New",80);
  textFont (font);
}

void draw() {
  if ( year != globalyear & year > globalyear){
  globalyear = year;
  textAlign(CENTER,CENTER);
  background(#d1d1d1);
  text(year,width/2,height/2);
  text("SMC",width/2,height/2-70);

  }
}


void oscEvent(OscMessage theOscMessage)
{
  // get the first value as an integer
  int firstValue = theOscMessage.get(0).intValue();
   year = firstValue; 
  

  // get the second value as a float
  float secondValue = theOscMessage.get(1).floatValue();

  // get the third value as a string
  String thirdValue = theOscMessage.get(2).stringValue();

  // print out the message
  print("OSC Message Recieved: ");
  print(theOscMessage.addrPattern() + " ");
  println(firstValue + " " + secondValue + " " + thirdValue);
  //
}