(
SynthDef.new(\vinylCrackling, { arg out=0;
	var pop,imp,modImp,midNoise,hiNoise,loNoise,loopTime=8,numChan=2,w,x,y,env,atk=0.5, rel=0.5;

	//Harder pops
	pop = TDuty.ar(Dseq({ 1.0.bilinrand.abs } ! loopTime,inf));
	pop = Resonz.ar(Decay.ar(pop,TRand.ar(0.001,0.1,pop)),Demand.ar(pop,0,Dseq({ 7000.bilinrand.abs+40 } ! loopTime,inf)),
		mul:Demand.ar(pop,0,Dseq({ exprand(0.1,0.87) } ! loopTime,inf)));
	pop = LeakDC.ar(pop,TRand.ar(0.9,0.9995,pop));
	#w,x,y = PanB2.ar(pop,Demand.ar(pop,0,Dseq({ 1.0.rand2 } ! loopTime,inf)));

	//Softer, highpass filtered impulses
	imp = { arg i; HPF.ar(LPF.ar(Dust2.ar(8),8000.0),6000.0,WhiteNoise.ar(0.7)) } ! numChan;

	//Faster, modulated lowpass filtered impulses
	modImp = LPF.ar(Dust.ar(LFDNoise3.ar(1).exprange(100,500),LFDNoise3.ar(10).exprange(0.01,0.07)),9000.0) ! numChan;

	//Mid frequency modulated noise background
	midNoise = LPF.ar(GrayNoise.ar(LFDNoise3.ar(60))*WhiteNoise.ar(0.009),12000.0) ! numChan;

	//High frequency modulated noise background
	hiNoise = HPF.ar(LPF.ar(GrayNoise.ar(LFDNoise3.ar(60))*WhiteNoise.ar(0.01),14000.0),8000.0) ! numChan;

	//Low frequency modulated noise background
	loNoise = LPF.ar(BrownNoise.ar(PinkNoise.ar.range(0.001,0.02)),1200) ! numChan;

	env = EnvGen.kr(Env.new([0,0.4,0],[atk,rel],[0.8,-0.8]),doneAction:2);


	Out.ar(out,(DecodeB2.ar(numChan,w,x,y)+imp+modImp+midNoise+hiNoise+loNoise)*env);
	}).add;
)

s.sendMsg('/s_new',\vinylCrackling,a=s.nextNodeID,0,1,\out,0);
s.sendMsg('/n_free',a);