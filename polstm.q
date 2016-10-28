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
ESZ:10;
HSZ:10; / ESZ = 120
ISZ:4; / 

/ Softmax variables
SMPREDS:();
SMX:();
SMTARGETS:();
SMT:0;

/**************************L*S*T*M******************************************/
LWH:((3,HSZ,HSZ)#SAMPLER[MASTER;1000];
	(3,HSZ,HSZ)#SAMPLER[MASTER;1000];
	(3,HSZ,HSZ)#SAMPLER[MASTER;1000];
	(3,HSZ,HSZ)#SAMPLER[MASTER;1000]); /i,f,o,j
LWX:((3,HSZ,ESZ)#SAMPLER[MASTER;1000];
	(3,HSZ,ESZ)#SAMPLER[MASTER;1000];
	(3,HSZ,ESZ)#SAMPLER[MASTER;1000];
	(3,HSZ,ESZ)#SAMPLER[MASTER;1000]);
LB:((3,HSZ)#0f;
	(3,HSZ)#0f;
	(3,HSZ)#0f;
	3*(3,HSZ)#1f); / bi;bf;bo;bj
LDB:((3,HSZ)#0f;
	(3,HSZ)#0f;
	(3,HSZ)#0f;
	(3,HSZ)#0f); / bi;bf;bo;bj
LDWX:((3,HSZ,ESZ)#0f;
	(3,HSZ,ESZ)#0f;
	(3,HSZ,ESZ)#0f;
	(3,HSZ,ESZ)#0f); 
LDWH:((3,HSZ,HSZ)#0f;
	(3,HSZ,HSZ)#0f;
	(3,HSZ,HSZ)#0f;
	(3,HSZ,HSZ)#0f);
LSTMX:(3 1)#"0";

LSTMT:(0;0;0); / time pointer in LSTM
LSTMH:(3,1,HSZ)#0;
LSTMC:(3,1,HSZ)#0;
LSTMCT:(3 1)#"0";
/all gates here
LSTMIG:(3 1)#"0"; 
LSTMFG:(3 1)#"0";
LSTMOG:(3 1)#"0";
LSTMCUPD:(3 1)#"0";
LDHPREV:(3,1,HSZ)#0;
LDCPREV:(3,1,HSZ)#0;

GETLOSS:{[DUMMY]A::SMTARGETS,'reverse SMPREDS;:sum {neg log(A[x][A[x;0]+1])}each til count SMTARGETS};

LSTMFW:{[XT;TARGETS]
	LSTMT[L]::LSTMT[L]+1; 

	T:LSTMT[L];  H:"f"$LSTMH[L;T-1];

	k:(1%1+exp(-1*((LWH[0;L]$H)+(LWX[0;L]$XT)+LB[0;L])));
	LSTMIG[L]::(LSTMIG[L], enlist k);

	k:(1%1+exp(-1*((LWH[1;L]$H)+(LWX[1;L]$XT)+LB[1;L])));
	LSTMFG[L]::(LSTMFG[L], enlist k);

	k:(1%1+exp(-1*((LWH[2;L]$H)+(LWX[2;L]$XT)+LB[2;L])));
	LSTMOG[L]::(LSTMOG[L], enlist k);

	TMP:(LWH[3;L]$H)+(LWX[3;L]$XT)+LB[3;L];
	k:((exp(TMP)-exp(-1*TMP)))%((exp(TMP)+exp(-1*TMP)));
	LSTMCUPD[L]::(LSTMCUPD[L], enlist k);

	TMP:(raze LSTMIG[L;T]*LSTMCUPD[L;T])+(raze LSTMFG[L;T])*LSTMC[L;T-1];
	LSTMC[L]::(LSTMC[L], enlist TMP);

	TMP:((exp(TMP)-exp(-1*TMP)))%((exp(TMP)+exp(-1*TMP)));
 	LSTMCT[L]::(LSTMCT[L], enlist TMP);

	TMP:LSTMOG[L;T]*LSTMCT[L;T];
	LSTMH[L]::(LSTMH[L], enlist TMP);

	LSTMX[L]::(LSTMX[L], enlist XT);

	:LSTMh[L;T]
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
	LDWH[0;L]::LDWH[0;L]+(DINPUT*/:\: HIN);
	LDWH[1;L]::LDWH[1;L]+(DFORGET*/:\: HIN);
	LDWH[2;L]::LDWH[2;L]+(DOUTPUT*/:\: HIN);
	LDWH[3;L]::LDWH[3;L]+(DUPDATE*/:\: HIN);

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
 	LSTMT[L]::0;
	LSTMx[L]::"0";
	LSTMH[L]::(1,hsz)#0;
	LSTMC[L]::(1,hsz)#0;
	LSTMCT[L]::"0";

	LSTMIG[L]::"0"; 
	LSTMFG[L]::"0";
	LSTMOG[L]::"0";
	LSTMCUPD[L]::"0";

	LDHPREV[L]::(1,hsz)#0;
	LDCPREV[L]::(1,hsz)#0;
	INPUT:0;
	OUTPUT:1;
	if[L=OUTPUT;LSTMH[L;0]::LSTMH[INPUT;LSTMT[INPUT]];LSTMC[L;0]::LSTMC[INPUT;LSTMT[INPUT]]];
	if[L=INPUT;LDHPREV[L]::LDHPREV[OUTPUT];LDCPREV[L]::LDCPREV[OUTPUT]];

	LDB[;L;]::0.0;
	LDWX[;L;;]::0.0;
	LDWH[;L;;]::0.0;

	SMPREDS::();
	SMX::();
	SMTARGETS::();
	SMT::0;
	SMDW::(ISZ,HSZ)#0f
	};
/
softmax forward pass
\
SOFTMAXFW:{[IX] SMT::SMT+1;
	YY:raze SMW$IX;
	YY:exp(YY-max YY);
	YY:YY%sum YY;
	$[0=count SMPREDS;SMPREDS::(1,ISZ)#YY;SMPREDS::(SMPREDS, enlist YY)];
	$[0=count SMX;SMX::(1,HSZ)#IX;SMX::(SMX, enlist IX)];
	:YY};

/
softmax backward pass
\
SOFTMAXBW:{[i] SMT::SMT-1;
	$[0=count SMTARGETS;SMTARGETS::i;SMTARGETS::(SMTARGETS, enlist i)];
	TMPX:raze over ((HSZ,1)#SMX[SMT]);
	TMPD:raze over ((1,ISZ)#SMPREDS[SMT]);
	TMPD[i]:TMPD[i]-1;
	SMDW::SMDW+(TMPD */:\: TMPX);
	DELTA:(1,HSZ)#(flip SMW)$TMPD; 
	:DELTA
  };

NORMALIZEGRADS:{[N]LDWX::LDWX%N;LDWH::LDWH%N;EMBDW::EMBDW%N;SMDW::SMDW%N};
TAKESTEP:{[LR]LWX::LWX-LR*LDWX;LWH::LWH-LR*LDWH;LB::LB-LR*LDB;EMBW::EMBW-LR*EMBDW;SMW::SMW-LR*SMDW};

LR:0.1;
CLIPGRAD:5.0;
TRAIN:{[INPUT, TARGETS]
	INITLAYER[0];
	T:0;
	COST:0;
	/ Forward
	while[T<count INPUT;
		H:LSTMFW[INPUT[T], TARGETS[T]];
		COST:COST+SOFTMAXFW[H];	
		T+:1;
		];
	/ Backward
	while [T>0;
		H:SOFTMAXBW[TARGETS[T]];
		H:LSTMBW[H];
		T:-1;
		];
	GRADNORM: sqrt((sum over LDWX xexp 2)+(sum over LDWH xexp 2)+(sum over EMBDW xexp 2)+(sum over SMDW xexp 2));
	if[GRADNORM>CLIPGRAD;NORMALIZEGRADS(GRADNORM%CLIPGRAD)];
	TAKESTEP[LR];
	:COST
	};

 / Read text input
TXT:raze " " vs raze read0 `:polstm.q;
CHARS: distinct TXT;
VOCAB_SIZE:count CHARS;
P:0;
I:0;
CHAR_TO_IX:CHARS, 'til count CHARS;
SMOOTHLOSS:(neg log (1.0%VOCAB_SIZE)*SEQLEN);
SEQLEN:25;
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
