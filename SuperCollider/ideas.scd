(  // Wind Chimes

{var windspd, partials = 32;

windspd = LFDNoise3.kr(LFNoise1.kr(1, 0.5, 0.5), 0.5, 0.5);

{Mix.ar({

var trigger, key;

trigger = Dust.kr(windustdspd);

key = 220 * [1/1, 3/2, 4/3, 6/5, 16/9];



HPF.ar(Pan2.ar(

 Mix.ar(

  Array.fill(partials,

  { arg counter;

  var harmonic = counter + 1;

  if(harmonic%2 == 1,

  {SinOsc.ar({key.choose * harmonic + 8.4.sum3rand}) *

  EnvGen.kr(

   Env.perc(0, //attack

     windspd * (1/harmonic) + TRand.kr(-0.2, 0.2, trigger), //release

     windspd * (20/harmonic), //peak level

     (-2 - harmonic)), //curve

   trigger,                    //gate

   (windspd * TRand.kr(0.9, 1.0, trigger)) / harmonic  //levelScale

   )},

   {SinOsc.ar(mul:0)})

  })

 )/partials,

 0.5.sum3rand

), 500)

}.dup(6) )

} +



{Pan2.ar(

RLPF.ar(

in:WhiteNoise.ar(mul:1.0),

freq:windspd * 500 + 250,

rq:LFNoise1.kr(1, 0.3, 0.5),

mul:windspd * 0.3

),

LFDNoise3.kr(3/7, 0.5, 0))

}}.play;

)




(  // Wind Chimes
{var windspd, partials = 15, pars;
windspd = LFDNoise3.kr(LFNoise1.kr(1, 0.5, 0.5), 0.5, 0.5);
{Mix.ar({
var trigger, key;
trigger = Dust.kr(windspd);
key = 660 * [1/1, 3/2, 4/3, 6/5, 16/9];
pars = [];
1.forBy(partials.floor, 2, {arg thisPar; pars = pars.add(thisPar)});
DelayN.ar(HPF.ar(Pan2.ar(
Mix.ar(
 pars.collect(
 { arg counter;
         var harmonic = counter + 1;
DelayN.ar(
 SinOsc.ar({key.choose * harmonic + 8.4.sum3rand}) *
 EnvGen.kr(
  Env.perc(0, //attack
    windspd * 15 * (1/harmonic) + TRand.kr(-0.2, 0.2, trigger), //release
    windspd * (20/harmonic), //peak level
    (-2 - harmonic)), //curve
  trigger,                    //gate
  (windspd * TRand.kr(0.9, 1.0, trigger)) / harmonic  //levelScale
  ), 0.01, [Rand.new(0.0, 0.01), Rand.new(0.0, 0.01)])}))/partials,
0.5.sum3rand
), 500), 0.5, Rand.new(0.4, 0.5))
}.dup(6) ) * 0.2
} +

{GVerb.ar(
        RLPF.ar(
        in:WhiteNoise.ar(mul:1.0),
        freq:windspd * 500 + 350,
        rq:LFNoise1.kr(1, 0.3, 0.5),
        mul:windspd * 0.3 + 0.05
        ),
        200, 3, 0.5, 0.2, 15, 1, 0.2, 0.2, 201)
}}.play;
)

{
    var pitch,env,density,scale,root,sig,mod,trig,pan,volenv;
    volenv=EnvGen.kr(Env.linen(10,80,20),1,doneAction:2);
    density=LFTri.kr(0.01).range(0.01,2.5);
    trig=Dust.kr(density);
    root=Demand.kr(trig,0,Drand([72,60,48,36],inf));
    pan=TRand.kr(-0.4,0.4,trig);
    scale=root+[0,2,4,5,7,9,11,12];
    pitch=Demand.kr(trig,0,Drand(scale,inf));
    env=EnvGen.kr(Env.perc(0.001,0.3),trig);
    mod=SinOsc.ar(pitch.midicps*4,0,800)*env;
    sig=SinOsc.ar(pitch.midicps+mod,0,0.2);
    FreeVerb.ar(CombL.ar(Pan2.ar(sig*env,pan),5,0.2,5))*volenv;
}.play;

(
SynthDef(\test, {
	var pitch,env,density,scale,root,sig,mod,trig,pan,volenv;

    volenv=EnvGen.kr(Env.linen(10,80,20),1,doneAction:2);
    density=LFTri.kr(0.01).range(0.01,2.5);
    trig=Dust.kr(density);
    root=Demand.kr(trig,0,Drand([72,60,48,36],inf));
    pan=TRand.kr(-0.4,0.4,trig);
    scale=root+[0,2,4,5,7,9,11,12];
    pitch=Demand.kr(trig,0,Drand(scale,inf));
    env=EnvGen.kr(Env.perc(0.001,0.3),trig);
    mod=SinOsc.ar(pitch.midicps*4,0,800)*env;
    sig=SinOsc.ar(pitch.midicps+mod,0,0.2);

	Out.ar([0,1], FreeVerb.ar(CombL.ar(Pan2.ar(sig*env,pan),5,0.2,5))*volenv;);
}).store;
)

x = Synth(\test);

SynthDef(\wind, {
	var pitch;
	var sound;
	var env;

	sound = HPF.ar(WhiteNoise.ar(0.5), XLine.kr(800, 1800, 3)) * 0.05;

	3.do {|i|
		var filtered = RLPF.ar(WhiteNoise.ar(0.5), 1000, 0.1) * 0.1;
		sound = DelayN.ar(filtered, 1, 0.1*i, 0, sound * 0.7);
	};

	env = EnvGen.ar(
		Env.linen(0.2, 0, 2.8, 0.8, \welch),
		doneAction:2
	);

	Out.ar([0,1], sound * env);
}).store;



SynthDef("tutorial-NoRand", { Out.ar(0, SinOsc.ar(440 + 200.rand, 0, 0.2)) }).send(s);
x = Synth(\wind);