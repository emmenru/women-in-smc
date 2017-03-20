~sample= Buffer.read(s,"/Users/emmafrid/kurser/creative_coding/women-in-smc/SuperCollider/353194__inspectorj__wind-chimes-a.wav");

~sample2= Buffer.read(s,
"/Users/emmafrid/kurser/creative_coding/women-in-smc/SuperCollider/346642__inspectorj__rain-on-windows-interior-a.wav");


(
SynthDef(\grain, {arg pan, amp=1, dur, startrandomness; var grain, playbuff;
var startPos = startrandomness* ~sample.numFrames;
playbuff = PlayBuf.ar(2, ~sample, 1, 1, startPos: startPos, doneAction: 2);
grain= playbuff*(EnvGen.kr(Env.perc(0.05,0.9,0.5,dur),doneAction:2)-0.001)*amp;
Out.ar(0,Pan2.ar(grain, pan))}).add;
)

// alternative envelope
//(XLine.kr(1.001,0.001,0.1,doneAction:2)-0.001)

//listen to a single grain;
Synth(\grain,[\amp, exprand(0.7,1.0), \pan, 1.0.rand2, \dur, 0.15, \startrandomness, 1.0.rand]);

// possible male synth
(
SynthDef(\malegrain, {arg pan, amp=1, dur, startrandomness; var grain, playbuff;
var startPos = startrandomness* ~sample2.numFrames;
playbuff = PlayBuf.ar(2, ~sample2, 1, 1, startPos: startPos, doneAction: 2);
grain= playbuff*(EnvGen.kr(Env.perc(0.05,0.9,0.5,dur),doneAction:2)-0.001)*amp;
Out.ar(0,Pan2.ar(grain, pan))}).add;
)


Synth(\malegrain,[\amp, exprand(0.7,1.0), \pan, 1.0.rand2, \dur, 0.15, \startrandomness, 1.0.rand]);


