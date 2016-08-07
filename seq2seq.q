pi:acos -1

nor:{$[x=2*n:x div 2;raze sqrt[-2*log n?1f]*/:(sin;cos)@\:(2*pi)*n?1f;-1_.z.s 1+x]}
INPUT:0;
OUTPUT:1;
L:INPUT; / layer number
vocabsz:4;
vsz:4;
esz:10;
hsz:10;
isz:4;
osz:4;

/Embedding
embw:(2,vsz,esz)#(nor 100);
embdw:(2,vsz,esz)#0.0;
et:(2 1)#0; / time pointer in embedding
embx:2 1#(); 
/ LSTM
lWhi:(2,hsz,hsz)#nor 100;
lWhf:(2,hsz,hsz)#nor 100;
lWho:(2,hsz,hsz)#nor 100;
lWhj:(2,hsz,hsz)#nor 100;

lWxi:(2,hsz,esz)#nor 100;
lWxf:(2,hsz,esz)#nor 100;
lWxo:(2,hsz,esz)#nor 100;
lWxj:(2,hsz,esz)#nor 100;

lbi:(2,hsz)#0;
lbo:(2,hsz)#0;
lbj:(2,hsz)#0;
lbf:(2,hsz)#1;

ldWxi:(2,hsz,esz)#nor 100;
ldWxf:(2,hsz,esz)#nor 100;
ldWxo:(2,hsz,esz)#nor 100;
ldWxj:(2,hsz,esz)#nor 100;

ldWhi:(2,hsz,hsz)#nor 100;
ldWhf:(2,hsz,hsz)#nor 100;
ldWho:(2,hsz,hsz)#nor 100;
ldWhj:(2,hsz,hsz)#nor 100;

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

idhprev:(1,hsz)#0;
odhprev:(1,hsz)#0;
idcprev:(1,hsz)#0;
odcprev:(1,hsz)#0;

/ Softmax variables
smpreds:();
smx:();
smtargets:();
smt:0;
smw:(osz,hsz)#nor 100;
smdw:(osz,hsz)#0;

/ input forward
et[L]:0; / global time

/ input seq
X:(2;1); 

/ input forward - embedding, then lstm
ifw:{[t]show "Input seq. "; show X[t];h:embfw[X[t]];h:LSTMfw[h];$[t<(-1+count X);ifw[t+1];h]}

embfw:{[i]$[0=count embx[L;0];embx[L;0]::enlist i;embx[L;0]::(embx[L;0], enlist i)];et[L]::et[L]+1;embw[L;i]}

LSTMfw:{[xt]if[L=OUTPUT;LSTMh[L;0]::LSTMh[INPUT;LSTMt[INPUT]];LSTMc[L;0]::LSTMc[INPUT;LSTMt[INPUT]]];
	LSTMt[L]::LSTMt[L]+1;
	t:LSTMt[L];
	h:"f"$LSTMh[L;t-1];
	k:(1%1+exp(-1*((lWhi[L]$h)+(lWxi[L]$xt)+lbi[L])));
	LSTMig[L]::(LSTMig[L], enlist k);
	k:(1%1+exp(-1*((lWhf[L]$h)+(lWxf[L]$xt)+lbf[L])));
	LSTMfg[L]::(LSTMfg[L], enlist k);
	k:(1%1+exp(-1*((lWho[L]$h)+(lWxo[L]$xt)+lbo[L])));
	LSTMog[L]::(LSTMog[L], enlist k);
	tmp:(lWhj[L]$h)+(lWxj[L]$xt)+lbj[L];
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
kumar:ifw 0;
/show kumar;

/ output forward - Embedding, LSTM, softmax
L:OUTPUT;
EOS:0;
Y:1;
Y:(0;Y);
et[L]:0;

ofw:{[t]show "Output seq. ";show Y[t];h:embfw[Y[t]];h:LSTMfw[h];h:softmaxfw[h];$[t<(-1+count Y);ofw[t+1];h]}

softmaxfw:{[ix]smt::smt+1;y:smw$ix;y:exp(y-max(y));y:y%sum y;$[0=count smpreds;smpreds::y;smpreds::(smpreds;y)];$[0=count smx;smx::ix;smx::(smx;ix)];y}
kumar:ofw 0;
show "Predictions :";
show smpreds;
