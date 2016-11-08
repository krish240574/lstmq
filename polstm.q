/ Gaussian, mean 0 stdev 0.1 - 1000 numbers
GDIST:"F"$trim "," vs raze read0 `gdist.txt;
MASTER:til count GDIST;DATA:GDIST;FLIST:(); /vars for SAMPLER
SAMPLER:{[MASTER;C]while[C>count FLIST;
	SMPL:distinct (floor (count MASTER)%2)?(MASTER);
	$[0=count FLIST;
		FLIST::DATA[SMPL];
		FLIST::FLIST,DATA[SMPL]];
	m:MASTER[where not MASTER in SMPL]];
	:FLIST[til C]
 };
/ Read text input
TXT:raze " " vs raze read0 `:polstm.q;
CHARS: distinct TXT;
VOCAB_SIZE:count CHARS;
P:0;
I:0;
CHAR_TO_IX:CHARS, 'til count CHARS;
IX_TO_CHARS:(til count CHARS),'CHARS;
SEQLEN:25;

ESZ:VOCAB_SIZE;
HSZ:VOCAB_SIZE; 
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

LSTMFW:{[XT] L:0;
	LSTMT::LSTMT+1; 

	T:LSTMT;  H:"f"$LSTMH[T-1];

	k:(1%1+exp(-1*((LWH[0]$H)+(LWX[0]$XT)+LB[0])));
	LSTMIG::(LSTMIG, enlist k);

	k:(1%1+exp(-1*((LWH[1]$H)+(LWX[1]$XT)+LB[1])));
	LSTMFG::(LSTMFG, enlist k);

	k:(1%1+exp(-1*((LWH[2]$H)+(LWX[2]$XT)+LB[2])));
	LSTMOG::(LSTMOG, enlist k);

	TMP:(LWH[3]$H)+(LWX[3]$XT)+LB[3];
	k:((exp(TMP)-exp(-1*TMP)))%((exp(TMP)+exp(-1*TMP)));
	LSTMCUPD::(LSTMCUPD, enlist k);

	TMP:(raze LSTMIG[T]*LSTMCUPD[T])+(raze LSTMFG[T])*LSTMC[T-1];
	LSTMC::(LSTMC, enlist TMP);
	
	TMP:((exp(TMP)-exp(-1*TMP)))%((exp(TMP)+exp(-1*TMP)));
 	LSTMCT::(LSTMCT, enlist TMP);

	TMP:LSTMOG[T]*LSTMCT[T];
	LSTMH::(LSTMH, enlist TMP);

	LSTMX::(LSTMX, enlist XT);
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

	LDCPREV::flip LSTMFG[T]*DC; 

	LDB[0]::LDB[0]+DINPUT;
	LDB[1]::LDB[1]+DFORGET;
	LDB[2]::LDB[2]+DOUTPUT; 
	LDB[3]::LDB[3]+DUPDATE; 

	HIN:LSTMH[T-1]; 

	LDWX[0]::LDWX[0]+(DINPUT*/:\: raze LSTMX[T]); 
	LDWX[1]::LDWX[1]+(DFORGET*/:\: raze LSTMX[T]);
	LDWX[2]::LDWX[2]+(DOUTPUT*/:\: raze LSTMX[T]); 
	LDWX[3]::LDWX[3]+(DUPDATE*/:\: raze LSTMX[T]);

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

	LSTMH:(1,HSZ)#0.0;
	LSTMC:(1,HSZ)#0.0;

	LDB:((1,HSZ)#0f;
	(1,HSZ)#0f;
	(1,HSZ)#0f;
	(1,HSZ)#0f); / bi;bf;bo;bj

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
SOFTMAXFW:{[IX] SMT::SMT+1;
	YY:raze SMW$IX;
	YY:exp(YY-max YY);
	YY:YY%sum YY;
	$[0=count SMPREDS;SMPREDS::(1,OSZ)#YY;SMPREDS::(SMPREDS, enlist YY)];
	$[0=count SMX;SMX::(1,HSZ)#IX;SMX::(SMX, enlist IX)];
	:YY};

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

NORMALIZEGRADS:{[N]show N;LDWX::LDWX%N;LDWH::LDWH%N;SMDW::SMDW%N};
TAKESTEP:{[LR]LWX::LWX-LR*LDWX;LWH::LWH-LR*LDWH;LB::LB-LR*LDB;SMW::SMW-LR*SMDW};

LR:0.1;
CLIPGRAD:5.0;
XS:();
TRAIN:{[INPUT;TARGETS]
	/ One-of-K input
	INITLAYER[0];
	T:0;
	COST:0;
	/ Forward
	while[T<count INPUT;
		XS::raze (1,VOCAB_SIZE)#0;
		XS[INPUT[T][1]]:1;
		H:LSTMFW["f"$(VOCAB_SIZE,1)#XS];
		TMP:(SOFTMAXFW[H])[[TARGETS[T];0]];
		COST+:TMP;	
		T+:1;
		];
	/ Backward
	T:T-1;
	while [T>0;
		H:SOFTMAXBW[TARGETS[T][1]];
		H:LSTMBW[H];
		T:T-1;
		show "_________________";
		show TARGETS[T][1];
		show "_________________";
		];

	/ Normalize and SGD
	GRADNORM:sqrt((sum over LDWX xexp 2)+(sum over LDWH xexp 2)+(sum over SMDW xexp 2));
	if[GRADNORM>CLIPGRAD;NORMALIZEGRADS(GRADNORM%CLIPGRAD)];
	TAKESTEP[LR];
	/show GRADNORM;
	show "Cost = ";
	show COST;
	:COST
	};

SAMPLE:{[SEED;N]
	XT:raze (1,VOCAB_SIZE)#0;
	XT[SEED]:1;
	I:0;
	KIX:();
	while[I<N;
			INITLAYER[0];

			H:LSTMFW["f"$(VOCAB_SIZE,1)#XT];
			H:SOFTMAXFW[H];
LS
			XT:raze (1,VOCAB_SIZE)#0;
			INDEX:sum 1?count H;
			XT[INDEX]:1;
			$[0=count KIX;KIX:INDEX;KIX:KIX,INDEX];

			I+:1;
		];
		:KIX;
	};


I:0;
/ SMOOTHLOSS:(neg log (1.0%VOCAB_SIZE)*SEQLEN);
while [I<1000000;
		if[(I=0) or (P+SEQLEN+1)>=count INPUT;P:0];
	 / Start sending batches of chars to the LSTM
	 	INPUT:TXT[P+til(SEQLEN)];
	 	INPUT:INPUT,'(CHARS?INPUT);

	 	TARGETS:TXT[(P+1)+til(SEQLEN)];
	 	TARGETS:TARGETS,'(CHARS?TARGETS);

	 	COST:TRAIN[INPUT;TARGETS];
	 	/ SMOOTHLOSS:SMOOTHLOSS*0.999+COST*0.001;
	 	/ show "Smooth loss = ";
	 	/ show SMOOTHLOSS;
	 	I+:1;
	 	P+:1;

	 	/Sample from NN periodically
	 	N:200;
	 	SAMPLEIX:SAMPLE[INPUT[0][1];N];
	 	show IX_TO_CHARS[SAMPLEIX;1];
 	];
