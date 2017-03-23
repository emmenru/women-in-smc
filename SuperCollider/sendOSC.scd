Submit Browse Anonymous Login RSS
SuperCollider Code
«SuperCollider sending data to Processing» by Luigi Tamagnini on 09 Sep'13 10:57 in oscaudiovisualprocessing
first in SC i analyse audio data with some useful UGens: Onsets, SendTrig and SendPeakRMS; this data is then polled back to de client and dispatched to Processing via NetAddr and OSCFunc classes in Processing i receive the incoming messages and simple trig a draw function with the callback oscEvent (use oscP5 and netP5 libs
copy log fork json
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
// Tracking audio data
///////////////////////////////////

SynthDef(\pulse,{
	var sig, chain, onsets;
	sig = SinOsc.ar(Rand(220.0,440.0))
	*EnvGen.ar(Env.perc(releaseTime:0.5),Dust.ar(0.5))*0.7;
	Out.ar(0,sig !2);
	//
	chain = FFT({LocalBuf(512, 1)}, sig);
	onsets = Onsets.kr(chain,0.1,\power);
	SendTrig.kr(onsets);
	SendPeakRMS.kr(sig, 20, 3, "/replyAddress");
}).add;
Synth(\pulse)

~host = NetAddr("localhost", 4859); // address de PROCESSING


o = OSCFunc({ arg msg, time;
	[time, msg].postln;
	~host.sendMsg("/trigger",42,12.34,"hello processing");
},'/tr', s.addr);

p = OSCFunc({ |msg|
	"peak: %, rms: %".format(msg[3], msg[4]).postln
}, '/replyAddress');

//////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// Processing code

// OSC RECEIVE
import oscP5.*;
import netP5.*;

OscP5 oscP5;                 // objet for OSC send and receive
NetAddress myRemoteLocation;  // objet for service address

void setup() {
  size(400,400);
  oscP5 = new OscP5(this,4859); // start OSC and listen port ...
  // set remote location to localhost SuperColider port
  myRemoteLocation = new NetAddress("127.0.0.1",4859);
}

void draw() {
}


void oscEvent(OscMessage theOscMessage)
{
  // get the first value as an integer
  int firstValue = theOscMessage.get(0).intValue();

  // get the second value as a float
  float secondValue = theOscMessage.get(1).floatValue();

  // get the third value as a string
  String thirdValue = theOscMessage.get(2).stringValue();

  // print out the message
  print("OSC Message Recieved: ");
  print(theOscMessage.addrPattern() + " ");
  println(firstValue + " " + secondValue + " " + thirdValue);
  //

  rect(random(width),random(height),random(10),random(10));
}
raw 1870 chars (focus & ctrl+a+c to copy)
// Tracking audio data
///////////////////////////////////

SynthDef(\pulse,{
	var sig, chain, onsets;
	sig = SinOsc.ar(Rand(220.0,440.0))
	*EnvGen.ar(Env.perc(releaseTime:0.5),Dust.ar(0.5))*0.7;
	Out.ar(0,sig !2);
	//
	chain = FFT({LocalBuf(512, 1)}, sig);
	onsets = Onsets.kr(chain,0.1,\power);
	SendTrig.kr(onsets);
	SendPeakRMS.kr(sig, 20, 3, "/replyAddress");
}).add;
Synth(\pulse)

~host = NetAddr("localhost", 4859); // address de PROCESSING


o = OSCFunc({ arg msg, time;
	[time, msg].postln;
	~host.sendMsg("/trigger",42,12.34,"hello processing");
},'/tr', s.addr);

p = OSCFunc({ |msg|
	"peak: %, rms: %".format(msg[3], msg[4]).postln
}, '/replyAddress');

//////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
