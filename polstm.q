/ Check sampler
/ Xavier gdist
/ Check sampling of H
tanh:{((exp(x)-exp(-1*x)))%((exp(x)+exp(-1*x)))};
sigmoid:{1%(1+exp neg x)}

/ Gaussian, mean 0 stdev 0.1 - 1000 numbers
GDIST:"F"$trim "," vs raze read0 `gdist.txt;
/ sampler[] samples C numbers from a MASTER list
MASTER:til count GDIST;DATA:GDIST;FLIST:(); /vars for SAMPLER
SAMPLER:{[MASTER;C]
	while[C>count FLIST;
		SMPL:distinct (floor (count MASTER)%2)?(MASTER);
		$[0=count FLIST;
			FLIST::DATA[SMPL];
			FLIST::FLIST,DATA[SMPL]
		];
		m:MASTER[where not MASTER in SMPL]
	];
	:0.01*FLIST[til C]
 };
/ Read text input - shakespearean text
k:read0 `:cmplshake.txt;
/ Remove multiple spaces, only one space.
cleanText:{x where(or)':[not " "=x]};
TXT:" " sv cleanText over 'k;
/TXT:" " sv k[where (count each k="\"")>0];
CHARS: distinct TXT;
VOCAB_SIZE:count CHARS;
P:0;
I:0;
/ Utility methods - characters to index, and vice versa
CHAR_TO_IX:CHARS, 'til count CHARS;
IX_TO_CHARS:(til count CHARS),'CHARS;
SEQLEN:25; / For now

ESZ:VOCAB_SIZE;
HSZ:25; 
OSZ:VOCAB_SIZE; 

/ Softmax variables
SMPREDS:();
SMX:();
SMTARGETS:();
SMT:0;
SMW:(OSZ,HSZ)#SAMPLER[MASTER;1000]; /osz,hsz
SMDW:(OSZ,HSZ)#SAMPLER[MASTER;1000]; /osz,hsz

/**************************L*S*T*M******************************************/
LWH:((HSZ,HSZ)#SAMPLER[MASTER;1000];
	(HSZ,HSZ)#SAMPLER[MASTER;1000];
	(HSZ,HSZ)#SAMPLER[MASTER;1000];
	(HSZ,HSZ)#SAMPLER[MASTER;1000]); /i,f,o,j
LWX:((HSZ,ESZ)#SAMPLER[MASTER;1000];
	(HSZ,ESZ)#SAMPLER[MASTER;1000];
	(HSZ,ESZ)#SAMPLER[MASTER;1000];
	(HSZ,ESZ)#SAMPLER[MASTER;1000]);
LB:((HSZ)#0f;(HSZ)#0f;(HSZ)#0f;(HSZ)#0f); / bi;bf;bo;bj
LDB:((HSZ)#0f;(HSZ)#0f;(HSZ)#0f;(HSZ)#0f); / bi;bf;bo;bj

LDWX:((HSZ,ESZ)#0f;
	(HSZ,ESZ)#0f;
	(HSZ,ESZ)#0f;
	(HSZ,ESZ)#0f); 
LDWH:((HSZ,HSZ)#0f;
	(HSZ,HSZ)#0f;
	(HSZ,HSZ)#0f;
	(HSZ,HSZ)#0f);
LSTMX:(1 1)#"0";

LSTMT:0; / time pointer in LSTM
LSTMH:(1,HSZ)#0.0;
LSTMC:(1,HSZ)#0.0;
LSTMCT:(1 1)#"0";
/all gates here
LSTMIG:(1 1)#"0"; 
LSTMFG:(1 1)#"0";
LSTMOG:(1 1)#"0";
LSTMCUPD:(1 1)#"0";
LDHPREV:(1,HSZ)#0;
LDCPREV:(1,HSZ)#0;

GETLOSS:{[DUMMY]A::SMTARGETS,'reverse SMPREDS;:sum {neg log(A[x][A[x;0]+1])}each til count SMTARGETS};

LSTMFW:{[XT;SF] L:0;
	LSTMT::LSTMT+1; 

	T:LSTMT;  H:"f"$LSTMH[T-1];
	K:raze H;K[where K=0f]:0.0;H:(shape H)#K;

	ki:sigmoid[((LWH[0]$H)+(LWX[0]$XT)+LB[0])];
	ki[where raze ki<-1e-25]:-1e-25;

	kf:sigmoid[((LWH[1]$H)+(LWX[1]$XT)+LB[1])];
	kf[where raze kf<-1e-25]:-1e-25;

	ko:sigmoid[((LWH[2]$H)+(LWX[2]$XT)+LB[2])];
	ko[where raze ko<-1e-25]:-1e-25;

	TMP:(LWH[3]$H)+(LWX[3]$XT)+LB[3];
	ku:tanh[TMP];
	ku[where raze ku<-1e-25]:-1e-25;

	if[0=SF;
		LSTMIG::(LSTMIG, enlist ki);
		LSTMFG::(LSTMFG, enlist kf);
		LSTMOG::(LSTMOG, enlist ko);
		LSTMCUPD::(LSTMCUPD, enlist ku);
	];

	TMPC:(raze ki*ku)+(raze kf)*LSTMC[T-1];
	TMPC[where raze TMPC<1e-25]:-1e-25;

	TMPCT:tanh[TMPC];
	TMPCT[where raze TMPCT<1e-25]:-1e-25;


	TMPH:ko*TMPCT;
	t:raze TMPH;
	t[where t<-1e-25]:-1e-25;
	TMPH:(HSZ,1)#t;
/	TMPH[where raze TMPH<1e-25]:-1e-25;

 	if[0=SF;
 		LSTMC::(LSTMC, enlist TMPC);
 		LSTMCT::(LSTMCT, enlist TMPCT);
 		LSTMH::(LSTMH, enlist TMPH);
		LSTMX::(LSTMX, enlist raze XT);
 		];

	:LSTMH[T]
   };

LSTMBW:{[DH] T:LSTMT;
	
	DH:DH+ LDHPREV; 

	TMP:raze LSTMCT[T]; 
	DC:raze ((1-TMP*TMP)*LSTMOG[T]* flip DH)+raze LDCPREV; 

	TMP:LSTMIG[T]; 
	DINPUT:raze (TMP*(1-TMP))*LSTMCUPD[T]*DC; 

	TMP:LSTMFG[T]; 
	DFORGET:raze (TMP*(1-TMP))*LSTMC[T-1]*DC; 

	TMP:LSTMOG[T]; 
	DOUTPUT:raze (TMP*(1-TMP))*LSTMCT[T]*flip DH; 

	TMP:LSTMCUPD[T]; 
	DUPDATE:raze (1-TMP*TMP)*LSTMIG[T]*DC; 

	LDCPREV::flip (HSZ,1)#LSTMFG[T]*DC; 
/	show shape LDCPREV;

	LDB[0]::LDB[0]+DINPUT;
	LDB[1]::LDB[1]+DFORGET;
	LDB[2]::LDB[2]+DOUTPUT; 
	LDB[3]::LDB[3]+DUPDATE; 

	HIN:LSTMH[T-1]; 

	LDWX[0]::LDWX[0]+(DINPUT*/:\: LSTMX[T]); 
	LDWX[1]::LDWX[1]+(DFORGET*/:\: LSTMX[T]);
	LDWX[2]::LDWX[2]+(DOUTPUT*/:\: LSTMX[T]); 
	LDWX[3]::LDWX[3]+(DUPDATE*/:\: LSTMX[T]);

	LDWH[0]+::(DINPUT*/:\:  raze HIN);
	LDWH[1]+::(DFORGET*/:\: raze HIN);
	LDWH[2]+::(DOUTPUT*/:\: raze HIN);
	LDWH[3]+::(DUPDATE*/:\: raze HIN);

	LDHPREV::(1,HSZ)#(LWH[0]$DINPUT);
	LDHPREV::LDHPREV+(1,HSZ)#(LWH[1]$DFORGET);
	LDHPREV::LDHPREV+(1,HSZ)#(LWH[2]$DOUTPUT);
	LDHPREV::LDHPREV+(1,HSZ)#(LWH[3]$DUPDATE);

	dX:(flip LWX[0])$DINPUT;
	dX:dX+(flip LWX[1])$DFORGET;
	dX:dX+(flip LWX[2])$DOUTPUT;
	dX:dX+(flip LWX[3])$DUPDATE;

	LSTMT::LSTMT-1;
	:dX
 };

INITLAYER:{[L]
 	LSTMT::0;
	LSTMX::"0";
	LSTMCT::"0";

	LSTMIG::"0"; 
	LSTMFG::"0";
	LSTMOG::"0";
	LSTMCUPD::"0";
	LDHPREV::(1,HSZ)#0;
	LDCPREV::(1,HSZ)#0;

	LSTMH::(1,HSZ)#0.0;
	LSTMC::(1,HSZ)#0.0;

/	LDB::((1,HSZ)#0f; (1,HSZ)#0f; (1,HSZ)#0f; (1,HSZ)#0f); / bi;bf;bo;bj
	LDB::((HSZ)#0f;(HSZ)#0f;(HSZ)#0f;(HSZ)#0f); / bi;bf;bo;bj

	LDWX[;;]::0.0;
	LDWH[;;]::0.0;

	SMPREDS::();
	SMX::();
	SMTARGETS::();
	SMT::0;
	SMDW::(OSZ,HSZ)#0f
	};
/
softmax forward pass
\
SOFTMAXFW:{[IX;SF] SMT::SMT+1;
	K:raze IX;K[where K=0f]:0.0;IX:(shape IX)#K;
	YY:raze SMW$IX;
	YY:exp(YY-max YY);
	YY:YY%sum YY;
	if[0=SF;
		$[0=count SMPREDS;SMPREDS::(1,OSZ)#YY;SMPREDS::(SMPREDS, enlist YY)];
		$[0=count SMX;SMX::(1,HSZ)#IX;SMX::(SMX, enlist IX)];
	];
	:neg log SMPREDS[(SMT-1);TARGETS[SMT-1;1]]};
/	:YY};

/
softmax backward pass
\
SOFTMAXBW:{[i] SMT::SMT-1;
	$[0=count SMTARGETS;SMTARGETS::i;SMTARGETS::(SMTARGETS, enlist i)];
	TMPX:raze over ((HSZ,1)#SMX[SMT]);
	TMPD:raze over ((1,OSZ)#SMPREDS[SMT]);
	TMPD[i]:TMPD[i]-1;
	SMDW::SMDW+(TMPD */:\: TMPX);
	DELTA:(1,HSZ)#(flip SMW)$TMPD; 
	:DELTA
  };

NORMALIZEGRADS:{[N]LDWX::LDWX%N;LDWH::LDWH%N;SMDW::SMDW%N};
TAKESTEP:{[LR]LWX::LWX-LR*LDWX;LWH::LWH-LR*LDWH;{tx:raze LDWX[x];th:raze LDWH[x];th[where th<-1e-50]:-1e-50;tx[where tx<-1e-50]:-1e-50;LDWH[x]:(shape LDWH[x])#th;LDWX[x]:(shape LDWX[x])#tx;}each til count LDWX;LB::LB-LR*LDB;SMW::SMW-LR*SMDW};

LR:0.1;
CLIPGRAD:5.0;
XS:();
TRAIN:{[INPUT;TARGETS]
	T:0;
	COST:0.0;
	SF:0;
	INITLAYER[0];
	/ Forward
	while[T<count INPUT;
		XS::raze (1,VOCAB_SIZE)#0;
		XS[INPUT[T][1]]:1;
		H:LSTMFW[("f"$(VOCAB_SIZE,1)#XS);SF];
		K:raze H;K[where K=0f]:0.0;H:(shape H)#K;
		/TMP:(SOFTMAXFW[H;SF])[[TARGETS[T];0]];
		TMP:SOFTMAXFW[H;SF];
		COST+:TMP;	
		T+:1;
		];
	/ Backward
	T:T-1;
	while [T>0;
		H:SOFTMAXBW[TARGETS[T][1]];
		H:LSTMBW[H];
		T:T-1;
		];

	/ Normalize and SGD
	GRADNORM:sqrt((sum over LDWX xexp 2)+(sum over LDWH xexp 2)+(sum over SMDW xexp 2));
	if[GRADNORM>CLIPGRAD;NORMALIZEGRADS(GRADNORM%CLIPGRAD)];
	TAKESTEP[LR];
	/show GRADNORM;
	/show "Cost = ";
	/show COST;
	:COST
	};
SAMPLE:{[SEED;N]
	XT:"f"$raze (1,VOCAB_SIZE)#0;
	XT[SEED]:1.0;
	I:0;
	KIX:();
	SF:1;
	show "Sampling...";
/	INITLAYER[0];
	while[I<N;
/			H:LSTMFW["f"$(VOCAB_SIZE,1)#XT;SF];
/			H:SOFTMAXFW[H;SF];

			/ Pass through the entire LSTM to get new H
			H:LSTMH[LSTMT];
			t:sigmoid[(LWH[til 3]$\:H)+(LWX[til 3]$\:XT)];
			s:tanh[((LWX[3]$XT)+(LWH[3]$H))];
			H:t[2]*tanh((t[0]*s)+t[1]*LSTMC[LSTMT]);
			/ Now softmax to get final preds
			Y:raze SMW$H;
			H:(exp Y)%(sum exp Y);
			XT:"f"$raze (1,VOCAB_SIZE)#0;
			INDEX:sum 1?(idesc H)[til 10];
			XT[INDEX]:1f;
			$[0=count KIX;KIX:INDEX;KIX:KIX,INDEX];
			I+:1;
		];
		:KIX;
	};
	

I:0;
INITLAYER[0];
/ SMOOTHLOSS:(neg log (1.0%VOCAB_SIZE)*SEQLEN);
while [I<1000000;

		if[(I=0) or ((P+SEQLEN+1)>=count TXT);P:0;LSTMC:(1,HSZ)#0.0;LSTMH:(1,HSZ)#0.0];

	 	/ Start sending batches of chars to the LSTM
		INPUT:TXT[P+til SEQLEN];
	 	INPUT:INPUT,'(CHARS?INPUT);

	 	TARGETS:TXT[(P+1)+til SEQLEN];
	 	TARGETS:TARGETS,'(CHARS?TARGETS);
	 	COST:TRAIN[INPUT;TARGETS];
	 	/ SMOOTHLOSS:SMOOTHLOSS*0.999+COST*0.001;
	 	/ show "Smooth loss = ";
	 	/ show SMOOTHLOSS;
	 	/show "Counter = ";
	 	if[0=I mod 10;show I];
	 	I+:1;
	 	P+:SEQLEN;
	 	
	 	/Sample from NN periodically
	 	if[0=I mod 100;
		 	SAMPLEIX:SAMPLE[INPUT[sum 1?count INPUT][1];200];
			/show GETLOSS[0];
		 	show (COST;IX_TO_CHARS[SAMPLEIX;1]);
			INITLAYER[0];
	 	];

		
	 	/show IX_TO_CHARS[-1+SAMPLEIX;1];
 	];

