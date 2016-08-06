pi:acos -1

nor:{$[x=2*n:x div 2;raze sqrt[-2*log n?1f]*/:(sin;cos)@\:(2*pi)*n?1f;-1_.z.s 1+x]}
INPUT:0;
OUTPUT:1;
L:INPUT; / layer number
vocabsz:4
vsz:4
esz:10
hsz:10
isz:4

/Embedding
embw:(2,vsz,esz)#(nor 100);
embdw:(2,vsz,esz)#0.0
et:0
embx::(); 
/ LSTM
lWhi:(2,hsz,hsz)#nor 100;
lWhf:(2,hsz,hsz)#nor 100;
lWho:(2,hsz,hsz)#nor 100;
lWhj:(2,hsz,hsz)#nor 100;

lWxi:(2,hsz,esz)#nor 100;
lWxf:(2,hsz,esz)#nor 100;
lWxo:(2,hsz,esz)#nor 100;
lWxj:(2,hsz,esz)#nor 100;

lbi:(2,hsz)#0
lbo:(2,hsz)#0
lbj:(2,hsz)#0
lbf:(2,hsz)#1

ldWxi:(2,hsz,esz)#nor 100;
ldWxf:(2,hsz,esz)#nor 100;
ldWxo:(2,hsz,esz)#nor 100;
ldWxj:(2,hsz,esz)#nor 100;

ldWhi:(2,hsz,hsz)#nor 100;
ldWhf:(2,hsz,hsz)#nor 100;
ldWho:(2,hsz,hsz)#nor 100;
ldWhj:(2,hsz,hsz)#nor 100;

LSTMx:(2 1)#"0"
LSTMt:(1 2)#0;
LSTMh:(2,1,hsz)#0
LSTMc:(2,1,hsz)#0
LSTMct:(2 1)#"0"

oLSTMx:()
oLSTMt:0;
oLSTMh:()
oLSTMc:()
oLSTMct:()

/all gates here
LSTMig:(2 1)#"0" / 2 rows, one for input and one for output
LSTMfg:(2 1)#"0"
LSTMog:(2 1)#"0"
LSTMcupd:(2 1)#"0"

oLSTMig:"0"
oLSTMfg:()
oLSTMog:()
oLSTMcupd:()

idhprev:(1,hsz)#0
odhprev:(1,hsz)#0
idcprev:(1,hsz)#0
odcprev:(1,hsz)#0

/ input forward
t:0 / global time
X:2 1 / input seq
input:0; / each unit of input seq

ifw:{input::X[t];h:embifw@t;h:LSTMifw@h;if[t<(count X);t::t+1];h}

embifw:{$[0=count embx;embx::input;embx::embx,input];et::et+1;embw[L;input]}
xt:embifw 0;
LSTMifw:{[xt]if[L=OUTPUT;LSTMh[L;LSTMt[L]]::LSTMh[INPUT;LSTMt[INPUT];LSTMc[L;LSTMt[L]]::LSTMc[INPUT;LSTMt[INPUT]];LSTMt[L]::LSTMt[L]+1;t:LSTMt[L];h:"f"$LSTMh[L;t-1];k:(1%1+exp(-1*((lWhi[L]$h)+(lWxi[L]$xt)+lbi[L])));LSTMig[L]::(LSTMig[L];k);k:(1%1+exp(-1*((lWhf[L]$h)+(lWxf[L]$xt)+lbf[L])));LSTMfg[L]::(LSTMfg[L];k);k:(1%1+exp(-1*((lWho[L]$h)+(lWxo[L]$xt)+lbo[L])));LSTMog[L]::(LSTMog[L];k);tmp:(lWhj[L]$h)+(lWxj[L]$xt)+lbj[L];k:(1-exp(-2*tmp))%(1+exp(-2*tmp));LSTMcupd[L]:(LSTMcupd[L];k);tmp:LSTMig[L;t]*LSTMcupd[L;t]+LSTMfg[L;t]*raze LSTMc[L;t-1];LSTMc[L]:(LSTMc[L];tmp);tmp:(1-exp(-2*tmp))%(1+exp(-2*tmp));LSTMct[L]:(LSTMct[L];tmp);tmp:LSTMog[L;t]*LSTMct[L;t];LSTMh[L]::(LSTMh[L];tmp);LSTMx[L]::(LSTMx[L];xt);LSTMh[L;t]}
kumar:LSTMifw xt;
show kumar;
/



        
