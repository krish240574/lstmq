nor:{$[x=2*n:x div 2;raze sqrt[-2*log n?1f]*/:(sin;cos)@\:(2*(acos -1))*n?1f;-1_.z.s 1+x]}

esz:10
hsz:10; / esz = 10 also
isz:4; / vsz=4 also;osz = 4 also


/Embedding
embw:(2,isz,hsz)#((nor 100)%100); /2,vsz,esz
embdw:(2,isz,hsz)#0.0; /2,vsz,esz
et:(0;0); / time pointer in embedding
embx:(2 1)#(); 
/ LSTM
Lwh:((2,hsz,hsz)#((nor 100)%100);(2,hsz,hsz)#((nor 100)%100);(2,hsz,hsz)#((nor 100)%100);(2,hsz,hsz)#((nor 100)%100)); /i,f,o,j
/ Lwhi:(2,hsz,hsz)#((nor 100)%100);
/ Lwhf:(2,hsz,hsz)#((nor 100)%100);
/ Lwho:(2,hsz,hsz)#((nor 100)%100);
/ Lwhj:(2,hsz,hsz)#((nor 100)%100);

Lwx:((2,hsz,esz)#((nor 100)%100);(2,hsz,esz)#((nor 100)%100);(2,hsz,esz)#((nor 100)%100);(2,hsz,esz)#((nor 100)%100));
/ Lwxi:(2,hsz,esz)#((nor 100)%100); / 2,hsz,esz , esz coult be different !
/ Lwxf:(2,hsz,esz)#((nor 100)%100); / 2,hsz,esz
/ Lwxo:(2,hsz,esz)#((nor 100)%100); / 2,hsz,esz
/ Lwxj:(2,hsz,esz)#((nor 100)%100); / 2,hsz,esz

Lb:((2,hsz)#0f;(2,hsz)#0f;(2,hsz)#0f;3*(2,hsz)#1f); / bi;bf;bo;bj
Ldb:((2,hsz)#0f;(2,hsz)#0f;(2,hsz)#0f;(2,hsz)#0f); / bi;bf;bo;bj

/ Lbi:(2,hsz)#0;
/ Lbo:(2,hsz)#0;
/ Lbj:(2,hsz)#0;
/ Lbf:(2,hsz)#1;

Ldwx:((2,hsz,esz)#0f;(2,hsz,esz)#0f;(2,hsz,esz)#0f;(2,hsz,esz)#0f); 
/ Ldwxi:(2,hsz,hsz)#((nor 100)%100); /2,hsz,esz
/ Ldwxf:(2,hsz,hsz)#((nor 100)%100); /2,hsz,esz
/ Ldwxo:(2,hsz,hsz)#((nor 100)%100); /2,hsz,esz
/ Ldwxj:(2,hsz,hsz)#((nor 100)%100); /2,hsz,esz

Ldwh:((2,hsz,hsz)#0f;(2,hsz,hsz)#0f;(2,hsz,hsz)#0f;(2,hsz,hsz)#0f);

/ Ldwhi:(2,hsz,hsz)#((nor 100)%100);
/ Ldwhf:(2,hsz,hsz)#((nor 100)%100);
/ Ldwho:(2,hsz,hsz)#((nor 100)%100);
/ Ldwhj:(2,hsz,hsz)#((nor 100)%100);

LSTMx:(2 1)#"0";
LSTMt:(0;0); / time pointer in LSTM
LSTMh:(2,1,hsz)#0;
LSTMc:(2,1,hsz)#0;
LSTMct:(2 1)#"0";

/all gates here
LSTMig:(2 1)#"0"; / 2 rows, one for input and one for output
LSTMfg:(2 1)#"0";
LSTMog:(2 1)#"0";
LSTMcupd:(2 1)#"0";

Ldhprev:(2,1,hsz)#0;
Ldcprev:(2,1,hsz)#0;


/ Softmax variables
smpreds:();
smx:();
smtargets:();
smt:0;
smw:(isz,hsz)#((nor 100)%100); /osz,hsz
smdw:(isz,hsz)#0; /osz,hsz

/ input seq
/X:(2;1); 

/ input forward - embedding, then lstm
ifw:{[iseq;t]L:0;
	/ show "IFProp:Input seq. "; 
	/ show iseq[t];
	h:embfw[L;iseq[t]];
	h:LSTMfw[L;h];
	$[t<(-1+count iseq);ifw[iseq;t+1];h]
 }

embfw:{[L;i]$[0=count embx[L;0];embx[L;0]::enlist i;embx[L;0]::(embx[L;0], enlist i)];
	et[L]::et[L]+1;
	embw[L;i]
 }

LSTMfw:{[L;xt]INPUT:0;OUTPUT:1;
	/if[L=OUTPUT;LSTMh[L;0]::LSTMh[INPUT;LSTMt[INPUT]];LSTMc[L;0]::LSTMc[INPUT;LSTMt[INPUT]]];
	
	LSTMt[L]::LSTMt[L]+1;
	t:LSTMt[L];

	h:"f"$LSTMh[L;t-1];

	k:(1%1+exp(-1*((Lwh[0;L]$h)+(Lwx[0;L]$xt)+Lb[0;L])));
	LSTMig[L]::(LSTMig[L], enlist k);

	k:(1%1+exp(-1*((Lwh[1;L]$h)+(Lwx[1;L]$xt)+Lb[1;L])));
	LSTMfg[L]::(LSTMfg[L], enlist k);

	k:(1%1+exp(-1*((Lwh[2;L]$h)+(Lwx[2;L]$xt)+Lb[2;L])));
	LSTMog[L]::(LSTMog[L], enlist k);

	tmp:(Lwh[3;L]$h)+(Lwx[3;L]$xt)+Lb[3;L];
	k:(1-exp(-2*tmp))%(1+exp(-2*tmp));
	LSTMcupd[L]::(LSTMcupd[L], enlist k);

	tmp:(raze LSTMig[L;t]*LSTMcupd[L;t])+(raze LSTMfg[L;t])*LSTMc[L;t-1];
	LSTMc[L]::(LSTMc[L], enlist tmp);

	tmp:(1-exp(-2*tmp))%(1+exp(-2*tmp));
	LSTMct[L]::(LSTMct[L], enlist tmp);

	tmp:LSTMog[L;t]*LSTMct[L;t];
	LSTMh[L]::(LSTMh[L], enlist tmp);

	LSTMx[L]::(LSTMx[L], enlist xt);

	LSTMh[L;t]
 }
/ifw[(2;1);0];

/ output forward - Embedding, LSTM, softmax
ofw:{[oseq;t]L:1;
	/ show "OFProp:Output seq. ";
	/ show oseq[t];
	h:embfw[L;oseq[t]];
	h:LSTMfw[L;h];
	h:softmaxfw[h];
	$[t<(-1+count oseq);ofw[oseq;t+1];h]
 }

softmaxfw:{[ix]smt::smt+1;
	y:smw$ix;
	y:exp(y-max(y));
	y:y%sum y;
	$[0=count smpreds;smpreds::(1,isz)#y;smpreds::(smpreds, enlist y)];
	$[0=count smx;smx::(1,hsz)#ix;smx::(smx, enlist ix)];
	y
 }

/ofw[(0;2);0];


/ Output layers - backward pass now.
/ Reverse the output sequence
obw:{[oseq;c]L:1;
	/ show "OBProp:Output sequence:";
	/ show oseq[c];
	dh:raze softmaxbw[oseq[c]];
	dh:LSTMbw[L;dh];
	dh:embbw[L;dh];
	$[c<(-1+count oseq);obw[oseq;c+1];dh]}

softmaxbw:{[i]smt::smt-1;
	$[0=count smtargets;smtargets::i;smtargets::(smtargets, enlist i)];
	tmpx:raze over ((hsz,1)#smx[smt]);
	tmpd:raze over ((1,isz)#smpreds[smt]);
	tmpd[i]:tmpd[i]-1;
	smdw::smdw+flip (tmpd*/:tmpx);
	delta:(1,hsz)#(flip smw)$tmpd; delta
 }


/ Need to check here, if there is a 'next'
/ In that case, use the dhprev from 'next'
/ Applicable when in a deep LSTM setup
/ Here, we're using one layer each for INPUT and
/ OUTPUT.
LSTMbw:{[L;dh]INPUT:0;OUTPUT:0;

	/if[L=INPUT;Ldhprev[L]::Ldhprev[OUTPUT];Ldcprev[L]::Ldcprev[OUTPUT]];
	
	t:LSTMt[L];
	dh:dh+raze Ldhprev[L]; 

	tmp:LSTMct[L;t]; 
	dC:((1-tmp*tmp)*LSTMog[L;t]*dh)+raze Ldcprev[L]; 

	tmp:LSTMig[L;t]; 
	dinput:(tmp*(1-tmp))*LSTMcupd[L;t]*dC; 

	tmp:LSTMfg[L;t]; 
	dforget:(tmp*(1-tmp))*LSTMc[L;t-1]*dC; 

	tmp:LSTMog[L;t]; 
	doutput:(tmp*(1-tmp))*LSTMct[L;t]*dh; 

	tmp:LSTMcupd[L;t]; 
	dupdate:(1-tmp*tmp)*LSTMig[L;t]*dC; 

	Ldcprev[L]::LSTMfg[L;t]*dC; 

	Ldb[0;L]::Ldb[0;L]+dinput;
	Ldb[1;L]::Ldb[1;L]+dforget;
	Ldb[2;L]::Ldb[2;L]+doutput; 
	Ldb[3;L]::Ldb[3;L]+dupdate; 

	hin:LSTMh[L;t-1]; 
	Ldwx[0;L]::Ldwx[0;L]+(dinput*/:LSTMx[L;t]); 
	Ldwx[1;L]::Ldwx[1;L]+(dforget*/:LSTMx[L;t]);
	Ldwx[2;L]::Ldwx[2;L]+(doutput*/:LSTMx[L;t]); 
	Ldwx[3;L]::Ldwx[3;L]+(dupdate*/:LSTMx[L;t]);
	
	Ldwh[0;L]::Ldwh[0;L]+(dinput*/:hin);
	Ldwh[1;L]::Ldwh[1;L]+(dforget*/:hin);
	Ldwh[2;L]::Ldwh[2;L]+(doutput*/:hin);
	Ldwh[3;L]::Ldwh[3;L]+(dupdate*/:hin);

	Ldhprev[L]::((flip Lwh[0;L])$dinput);
	Ldhprev[L]::Ldhprev[L]+((flip Lwh[1;L])$dforget);
	Ldhprev[L]::Ldhprev[L]+((flip Lwh[2;L])$doutput);
	Ldhprev[L]::Ldhprev[L]+((flip Lwh[3;L])$dupdate);

	dX:(flip Lwx[0;L])$dinput;
	dX:dX+(flip Lwx[1;L])$dforget;
	dX:dX+(flip Lwx[2;L])$doutput;
	dX:dX+(flip Lwx[3;L])$dupdate;
	LSTMt[L]::LSTMt[L]-1;
	dX };

embbw:{[L;delta]et[L]::et[L]-1;	tx:raze embx[L];tx:tx[et[L]];embdw[L;tx]::embdw[L;tx]+delta}


/input backward pass
ibw:{[iseq;c]L:0;
	/ show "IBProp:Input sequence:";
	/ show iseq[c];
	delta:raze (1,hsz)#0;
	delta:LSTMbw[L;delta];
	delta:embbw[L;delta];
	$[c<(-1+count iseq);ibw[iseq;c+1];delta]
 }

clipgrad:5.0;
lr:0.01;
normalizegrads:{[n]Ldwx::Ldwx%n;Ldwh::Ldwh%n;embdw::embdw%n;smdw::smdw%n};
takestep:{Lwx::Lwx-lr*Ldwx;Lwh::Lwh-lr*Ldwh;embw::embw-lr*embdw;smw::smw-lr*smdw;Lb::Lb-lr*Ldb};

/ Get cost for this training run
getCost:{[dummy]sum {-1*log((smpreds[x])[smtargets[x]])}each til count smtargets};

initLayer:{[L]
	
	embdw[L]::(isz,hsz)#0.0; 
	et[L]::0; 
	embx[L]::enlist (); 

	LSTMt[L]::0;
	LSTMx[L]::"0";
	LSTMh[L]::(1,hsz)#0;
	LSTMc[L]::(1,hsz)#0;
	LSTMct[L]::"0";

	LSTMig[L]::"0"; 
	LSTMfg[L]::"0";
	LSTMog[L]::"0";
	LSTMcupd[L]::"0";

	Ldhprev[L]::(1,hsz)#0;
	Ldcprev[L]::(1,hsz)#0;
	INPUT:0;
	OUTPUT:1;
	if[L=OUTPUT;LSTMh[L;0]::LSTMh[INPUT;LSTMt[INPUT]];LSTMc[L;0]::LSTMc[INPUT;LSTMt[INPUT]]];
	if[L=INPUT;Ldhprev[L]::Ldhprev[OUTPUT];Ldcprev[L]::Ldcprev[OUTPUT]];

	Ldb[;L;]::0.0;
	Ldwx[;L;;]::0.0;
	Ldwh[;L;;]::0.0;

	if[L=OUTPUT;
		smpreds::();
		smx::();
		smtargets::();
		smt::0;
		smdw::(isz,hsz)#0]; /osz,hsz
	}
/  Forward
/  Backward
train:{[iseq;oseq]L:0;initLayer[L];
	ifw[iseq;0];
	L:1;
	initLayer[L];
	ofw[(0;oseq);0];
	obw[reverse(oseq;0);0];
	ibw[reverse(iseq);0];
	gradnorm: sqrt((sum over Ldwx xexp 2)+(sum over Ldwh xexp 2) +(sum over embdw xexp 2)+(sum over smdw xexp 2));
	if[gradnorm>clipgrad;normalizegrads(gradnorm%clipgrad)];
	takestep[lr];
	:getCost[0]
 }
EOS:0;
maxl:10;
applyoutputmodel:{[prediction;token]
	tmp:token;
	tmp:ofw[(enlist tmp);0];

	token:sum where tmp = (max tmp);
	show token;
	/token:(asc tmp)[-1+count tmp];
	if[(token<>EOS) and (maxl > count prediction);
		$[0=count prediction;prediction:token;prediction:(prediction,enlist token)];
		applyoutputmodel[prediction;token]
	  ];
	:prediction
	}
/ Bubble input sequence through input layers
	/ Then send the output seq. to the output layers
	/ whilst using the h and c values from input layer LSTM
	/ as indicated in the paper
predict:{[iseq]L:0;
	initLayer[L];
	ifw[iseq;0];
	L:1;
	initLayer[L];
	prediction:();
	prediction:applyoutputmodel[prediction;0];
	show "Prediction =";
	show prediction;
	:prediction
 }


mainp:{[counter]
	cost:train[(2;1);2];
	cost:cost+train[enlist (1);1];
	cost:cost+train[(3;1);3];
	if[0 = (counter mod 100);
		show "Epoch:";
		show counter;
		show "Training cost:";
		show cost%3;	
		show "Predicting for [2,1] -> ";
		show predict[(2;1)];
		show "Predicting for [1] -> ";
		show predict[enlist (1)];
		show "Predicting for [3,1] -> ";
		show predict[(3;1)];
		show "---------------";];
		$[counter<1000;
			mainp[counter+1];
			show "Buh-bye"]
		 }

mainp[0]; 
