nor:{$[x=2*n:x div 2;raze sqrt[-2*log n?1f]*/:(sin;cos)@\:(2*(acos -1))*n?1f;-1_.z.s 1+x]}

vsz:4;
hsz:10; / esz = 10 also
isz:4; / osz = 4 also


/Embedding
embw:(2,vsz,hsz)#(nor 100); /2,vsz,esz
embdw:(2,vsz,hsz)#0.0; /2,vsz,esz
et:(2 1)#0; / time pointer in embedding
embx:2 1#(); 
/ LSTM
Lwhi:(2,hsz,hsz)#nor 100;
Lwhf:(2,hsz,hsz)#nor 100;
Lwho:(2,hsz,hsz)#nor 100;
Lwhj:(2,hsz,hsz)#nor 100;

Lwxi:(2,hsz,hsz)#nor 100; / 2,hsz,esz
Lwxf:(2,hsz,hsz)#nor 100; / 2,hsz,esz
Lwxo:(2,hsz,hsz)#nor 100; / 2,hsz,esz
Lwxj:(2,hsz,hsz)#nor 100; / 2,hsz,esz

Lbi:(2,hsz)#0;
Lbo:(2,hsz)#0;
Lbj:(2,hsz)#0;
Lbf:(2,hsz)#1;

Ldwxi:(2,hsz,hsz)#nor 100; /2,hsz,esz
Ldwxf:(2,hsz,hsz)#nor 100; /2,hsz,esz
Ldwxo:(2,hsz,hsz)#nor 100; /2,hsz,esz
Ldwxj:(2,hsz,hsz)#nor 100; /2,hsz,esz

Ldwhi:(2,hsz,hsz)#nor 100;
Ldwhf:(2,hsz,hsz)#nor 100;
Ldwho:(2,hsz,hsz)#nor 100;
Ldwhj:(2,hsz,hsz)#nor 100;

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
smw:(isz,hsz)#nor 100; /osz,hsz
smdw:(isz,hsz)#0; /osz,hsz

/ input seq
/X:(2;1); 

/ input forward - embedding, then lstm
ifw:{[iseq;t]L:0;show "IFProp:Input seq. "; show iseq[t];h:embfw[L;iseq[t]];h:LSTMfw[L;h];$[t<(-1+count iseq);ifw[iseq;t+1];h]}

embfw:{[L;i]$[0=count embx[L;0];embx[L;0]::enlist i;embx[L;0]::(embx[L;0], enlist i)];et[L]::et[L]+1;embw[L;i]}

LSTMfw:{[L;xt]INPUT:0;OUTPUT:1;if[L=OUTPUT;LSTMh[L;0]::LSTMh[INPUT;LSTMt[INPUT]];LSTMc[L;0]::LSTMc[INPUT;LSTMt[INPUT]]];
	
	LSTMt[L]::LSTMt[L]+1;
	t:LSTMt[L];

	h:"f"$LSTMh[L;t-1];

	k:(1%1+exp(-1*((Lwhi[L]$h)+(Lwxi[L]$xt)+Lbi[L])));
	LSTMig[L]::(LSTMig[L], enlist k);

	k:(1%1+exp(-1*((Lwhf[L]$h)+(Lwxf[L]$xt)+Lbf[L])));
	LSTMfg[L]::(LSTMfg[L], enlist k);

	k:(1%1+exp(-1*((Lwho[L]$h)+(Lwxo[L]$xt)+Lbo[L])));
	LSTMog[L]::(LSTMog[L], enlist k);

	tmp:(Lwhj[L]$h)+(Lwxj[L]$xt)+Lbj[L];
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
kumar:ifw[(2;1);0];
/show kumar;

/ output forward - Embedding, LSTM, softmax

ofw:{[oseq;t]L:1;show "OFProp:Output seq. ";show oseq[t];h:embfw[L;oseq[t]];h:LSTMfw[L;h];h:softmaxfw[h];$[t<(-1+count oseq);ofw[oseq;t+1];h]}

softmaxfw:{[ix]smt::smt+1;y:smw$ix;y:exp(y-max(y));y:y%sum y;$[0=count smpreds;smpreds::(1,isz)#y;smpreds::(smpreds, enlist y)];$[0=count smx;smx::(1,hsz)#ix;smx::(smx, enlist ix)];y}

kumar:ofw[(0;1);0];
show "Predictions :";
show smpreds;


/ Output layers - backward pass now.
/ Reverse the output sequence
/Y:reverse(Y);
show "Output backprop ::::::";
obw:{[oseq;t]L:1;show "OBProp:Output sequence:";h:softmaxbw[oseq[t]];dh:LSTMbw[L;h];h:embbw[L;h];$[t<(-1+count oseq);ofw[oseq;t+1];h]}

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
LSTMbw:{[L;dh]t:LSTMt[L];
	dh:raze over dh+Ldhprev[L]; 

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

	Lbi[L]::Lbi[L]+dinput;
	Lbf[L]::Lbf[L]+dforget;
	Lbo[L]::Lbo[L]+doutput; 
	Lbj[L]::Lbj[L]+dupdate; 

	hin:LSTMh[L;t-1]; 
	Ldwxi[L]::Ldwxi[L]+(dinput*/:LSTMx[L;t]); 
	Ldwxf[L]::Ldwxf[L]+(dforget*/:LSTMx[L;t]);
	Ldwxo[L]::Ldwxo[L]+(doutput*/:LSTMx[L;t]); 
	Ldwxj[L]::Ldwxj[L]+(dupdate*/:LSTMx[L;t]);
	
	Ldwhi[L]::Ldwhi[L]+(dinput*/:hin);
	Ldwhf[L]::Ldwhf[L]+(dforget*/:hin);
	Ldwho[L]::Ldwho[L]+(doutput*/:hin);
	Ldwhj[L]::Ldwhj[L]+(dupdate*/:hin);

	Ldhprev[L]::((flip Lwhi[L])$dinput);
	Ldhprev[L]::Ldhprev[L]+((flip Lwhf[L])$dforget);
	Ldhprev[L]::Ldhprev[L]+((flip Lwho[L])$doutput);
	Ldhprev[L]::Ldhprev[L]+((flip Lwhj[L])$dupdate);

	dX:(flip Lwxi[L])$dinput;
	dX:dX+(flip Lwxf[L])$dforget;
	dX:dX+(flip Lwxo[L])$doutput;
	dX:dX+(flip Lwxj[L])$dupdate;
	LSTMt[L]::LSTMt[L]-1;

	dX }
