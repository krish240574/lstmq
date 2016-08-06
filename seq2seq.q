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

lstmx:(2 1)#"0"
lstmt:0;
lstmh:(2,1,hsz)#0
lstmc:(2,1,hsz)#0
lstmct:(2 1)#"0"

olstmx:()
olstmt:0;
olstmh:()
olstmc:()
olstmct:()

/all gates here
lstmig:(2 1)#"0" / 2 rows, one for input and one for output
lstmfg:(2 1)#"0"
lstmog:(2 1)#"0"
lstmcupd:(2 1)#"0"

olstmig:"0"
olstmfg:()
olstmog:()
olstmcupd:()

idhprev:(1,hsz)#0
odhprev:(1,hsz)#0
idcprev:(1,hsz)#0
odcprev:(1,hsz)#0

/ input forward
t:0 / global time
X:2 1 / input seq
input:0; / each unit of input seq

ifw:{input::X[t];h:embifw@t;h:lstmifw@h;if[t<(count X);t::t+1];h}

embifw:{$[0=count embx;embx::input;embx::embx,input];et::et+1;embw[L;input]}
xt:embifw 0;
lstmifw:{[xt]lstmt::lstmt+1;t:lstmt;h:"f"$lstmh[L;t-1];k:(1%1+exp(-1*((lWhi[L]$h)+(lWxi[L]$xt)+lbi[L])));lstmig[L]::(lstmig[L];k);k:(1%1+exp(-1*((lWhf[L]$h)+(lWxf[L]$xt)+lbf[L])));lstmfg[L]::(lstmfg[L];k);k:(1%1+exp(-1*((lWho[L]$h)+(lWxo[L]$xt)+lbo[L])));lstmog[L]::(lstmog[L];k);tmp:(lWhj[L]$h)+(lWxj[L]$xt)+lbj[L];k:(1-exp(-2*tmp))%(1+exp(-2*tmp));lstmcupd[L]:(lstmcupd[L];k);tmp:lstmig[L;t]*lstmcupd[L;t]+lstmfg[L;t]*raze lstmc[L;t-1];lstmc[L]:(lstmc[L];tmp);tmp:(1-exp(-2*tmp))%(1+exp(-2*tmp));lstmct[L]:(lstmct[L];tmp);tmp:lstmog[L;t]*lstmct[L;t];lstmh[L]::(lstmh[L];tmp);lstmx[L]::(lstmx[L];xt);lstmh[L;t]}
kumar:lstmifw xt;
show kumar;
/if[L=OUTPUT;lstmh[L]::lstmh[INPUT;lstmt];lstmc[L]::lstmc[INPUT;lstmt]];



        
