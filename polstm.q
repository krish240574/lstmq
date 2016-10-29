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
 }
/ Read text input
TXT:raze " " vs raze read0 `:polstm.q;
CHARS: distinct TXT;
VOCAB_SIZE:count CHARS;
P:0;
I:0;
CHAR_TO_IX:CHARS, 'til count CHARS;
SEQLEN:25;

ESZ:VOCAB_SIZE;
HSZ:30; / ESZ = 120
OSZ:4; / 

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
LB:(0f;0f;0f;0f);
LDB:((1,HSZ)#0f;
	(1,HSZ)#0f;
	(1,HSZ)#0f;
	(1,HSZ)#0f); / bi;bf;bo;bj
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

LSTMBW:{[L;DH] T:LSTMT[L];FW:0;BW:1;DCDR:2;
	DH:DH+raze LDHPREV[L]; 

	TMP:raze LSTMCT[L;T]; 
	DC:raze ((1-TMP*TMP)*LSTMOG[L;T]*DH)+raze LDCPREV[L]; 

	TMP:LSTMIG[L;T]; 
	DINPUT:raze (TMP*(1-TMP))*LSTMCUPD[L;T]*DC; 

	TMP:LSTMFG[L;T]; 
	DFORGET:raze (TMP*(1-TMP))*LSTMC[L;T-1]*DC; 

	TMP:LSTMOG[L;T]; 
	DOUTPUT:raze (TMP*(1-TMP))*LSTMCT[L;T]*DH; 

	TMP:LSTMCUPD[L;T]; 
	DUPDATE:raze (1-TMP*TMP)*LSTMIG[L;T]*DC; 

	LDCPREV[L]::LSTMFG[L;T]*DC; 

	/LDB::LDB+((DINPUT;DFORGET;DOUTPUT;DUPDATE))
	LDB[0;L]::LDB[0;L]+DINPUT;
	LDB[1;L]::LDB[1;L]+DFORGET;
	LDB[2;L]::LDB[2;L]+DOUTPUT; 
	LDB[3;L]::LDB[3;L]+DUPDATE; 

	HIN:LSTMH[L;T-1]; 
	/LDWX::LDWX+((DINPUT*/:LSTMX[L;T]);(DFORGET*/:LSTMX[L;T]);(DOUTPUT*/:LSTMX[L;T]);(DUPDATE*/:LSTMX[L;T]))
	LDWX[0;L]::LDWX[0;L]+ (DINPUT*/:\: raze LSTMX[L;T]); 
	LDWX[1;L]::LDWX[1;L]+ (DFORGET*/:\: raze LSTMX[L;T]);
	LDWX[2;L]::LDWX[2;L]+ (DOUTPUT*/:\: raze LSTMX[L;T]); 
	LDWX[3;L]::LDWX[3;L]+ (DUPDATE*/:\: raze LSTMX[L;T]);
	/kumar;

	
	/LDWH::LDWH+((DINPUT*/:LSTMH[L;T]);(DFORGET*/:LSTMH[L;T]);(DOUTPUT*/:LSTMH[L;T]);(DUPDATE*/:LSTMH[L;T]))
	LDWH[0;L]::LDWH[0;L]+(DINPUT */:\: HIN);
	LDWH[1;L]::LDWH[1;L]+(DFORGET */:\: HIN);
	LDWH[2;L]::LDWH[2;L]+(DOUTPUT */:\: HIN);
	LDWH[3;L]::LDWH[3;L]+(DUPDATE */:\: HIN);

	/LDHPREV[L]::((flip LWH[0;L])$DINPUT) + ((flip LWH[1;L])$DFORGET) + ((flip LWH[2;L])$DOUTPUT) + ((flip LWH[3;L])$DUPDATE);
	/LDHPREV[L]::(flip LWH[0;L];flip LWH[1;L];flip LWH[2;L];flip LWH[3;L])$(4 1)#(DINPUT;DFORGET;DOUTPUT;DUPDATE)
	LDHPREV[L]::((flip LWH[0;L])$DINPUT);
	LDHPREV[L]::LDHPREV[L]+((flip LWH[1;L])$DFORGET);
	LDHPREV[L]::LDHPREV[L]+((flip LWH[2;L])$DOUTPUT);
	LDHPREV[L]::LDHPREV[L]+((flip LWH[3;L])$DUPDATE);

	/dX::(flip LWX[0;L];flip LWX[1;L];flip LWX[2;L];flip LWX[3;L])$(4 1)#(DINPUT;DFORGET;DOUTPUT;DUPDATE)
	dX:(flip LWX[0;L])$DINPUT;
	dX:dX+(flip LWX[1;L])$DFORGET;
	dX:dX+(flip LWX[2;L])$DOUTPUT;
	dX:dX+(flip LWX[3;L])$DUPDATE;
	LSTMT[L]::LSTMT[L]-1;
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

	LSTMH[;]:0.0;
	LSTMC[;]:0.0;

	LDB[;;]:0.0;
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

NORMALIZEGRADS:{[N]LDWX::LDWX%N;LDWH::LDWH%N;EMBDW::EMBDW%N;SMDW::SMDW%N};
TAKESTEP:{[LR]LWX::LWX-LR*LDWX;LWH::LWH-LR*LDWH;LB::LB-LR*LDB;EMBW::EMBW-LR*EMBDW;SMW::SMW-LR*SMDW};

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
		$[0=count XS;XS::(1,VOCAB_SIZE)#0;XS::XS,(1,VOCAB_SIZE)#0];
		XS[T;INPUT[T][1]]:1;
		H:LSTMFW["f"$(VOCAB_SIZE,1)#XS[T]];
		TMP:(SOFTMAXFW[H])[[TARGETS[T];0]];
		COST+:TMP;	
		T+:1;
		];
	/ Backward
	while [T>0;
		H:SOFTMAXBW[TARGETS[T]];
		H:LSTMBW[H];
		T:-1;
		];
	/ Normalize and SGD
	GRADNORM: sqrt((sum over LDWX xexp 2)+(sum over LDWH xexp 2)+(sum over EMBDW xexp 2)+(sum over SMDW xexp 2));
	if[GRADNORM>CLIPGRAD;NORMALIZEGRADS(GRADNORM%CLIPGRAD)];
	TAKESTEP[LR];
	:COST
	};

 
SMOOTHLOSS:(neg log (1.0%VOCAB_SIZE)*SEQLEN);
while [I<1000000;
 / Start sending batches of chars to the LSTM
 	INPUT:TXT[P+til(P+SEQLEN)];
 	INPUT:INPUT,'(CHARS?INPUT);
 	TARGETS:TXT[(P+1)+til(P+1+SEQLEN)];
 	TARGETS:TARGETS,'(CHARS?TARGETS);
 	COST:TRAIN[INPUT;TARGETS];
 	SMOOTHLOSS:SMOOTHLOSS*0.999+COST*0.001;
 	I+:1;
 	P+:1;
 	];
