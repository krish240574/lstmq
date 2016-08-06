pi:acos -1

nor:{$[x=2*n:x div 2;raze sqrt[-2*log n?1f]*/:(sin;cos)@\:(2*pi)*n?1f;-1_.z.s 1+x]}
INPUT:0;
OUTPUT:1;
L::INPUT; / layer number
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
lW_hi::(2,hsz,hsz)#nor 100;
lW_hf::(2,hsz,hsz)#nor 100;
lW_ho::(2,hsz,hsz)#nor 100;
lW_hj::(2,hsz,hsz)#nor 100;

lW_xi::(2,hsz,isz)#nor 100;
lW_xf::(2,hsz,isz)#nor 100;
lW_xo::(2,hsz,isz)#nor 100;
lW_xj::(2,hsz,isz)#nor 100;

lb_i::(2,hsz)#0
lb_o::(2,hsz)#0
lb_j::(2,hsz)#0
lb_f::(2,hsz)#1

ldW_xi::(2,hsz,isz)#nor 100;
ldW_xf::(2,hsz,isz)#nor 100;
ldW_xo::(2,hsz,isz)#nor 100;
ldW_xj::(2,hsz,isz)#nor 100;

ldW_hi::(2,hsz,isz)#nor 100;
ldW_hf::(2,hsz,isz)#nor 100;
ldW_ho::(2,hsz,isz)#nor 100;
ldW_hj::(2,hsz,isz)#nor 100;

ilstm_x::()
ilstm_t::0;
ilstm_h::(1,hsz)#0
ilstm_c::(1,hsz)#0
ilstm_ct::()

olstm_x::()
olstm_t::0;
olstm_h::()
olstm_c::()
olstm_ct::()

/all gates here
ilstm_ig::()
ilstm_fg::()
ilstm_og::()
ilstm_cupd::()

ilstm_ig::()
ilstm_fg::()
ilstm_og::()
ilstm_cupd::()

idh_prev::(1,hsz)#0
odh_prev::(1,hsz)#0
idc_prev::(1,hsz)#0
odc_prev::(1,hsz)#0

/ input forward
t::0 / global time
X::2 1 / input seq
input::0; / each unit of input seq

ifw:{input::X[t];h:emb_ifw@t;h:lstm_ifw@h;if[t<(count X);t::t+1];h}

emb_ifw:{embx[t]::input;et::et+1;embw[L;input]}
lstm_ifw:{[xt]
	/ If output layer, then take values from input layer, from *its* last time tick
	if[L=OUTPUT;olstmh::ilstmh[ilstmt];olstmc::ilstmc[ilstmt]];
	ilstmt::ilstmt+1;
	t:ilstmt;
	/ All calculations here are for THIS time step
	/ and for THIS node, the t-th node

	/ get h from previous node(from previous time step)
	h:ilstmh[t-1];
	/ use h and xt to calculate values for THIS node/time-step
	ilstm_ig[t]::sigmoid((lW_hi$h)+(lW_xi$xt)+lb_i);
	ilstm_fg[t]::sigmoid((lW_hf$h)+(lW_xf$xt)+lb_f);
	ilstm_og[t]::sigmoid((lW_ho$h)+(lW_xo$xt)+lb_o);
	ilstm_cupd[t]::tanh((lW_hj$h)+(Lw_xj$xt)+lb_j);
	/ cell states of THIS node/time-step
	ilstm_c[t]::ilstm_ig[t]*ilstm_cupd[t]*ilstm_fg[t]*ilstm_c[t-1];
	ilstm_ct[t]::tanh(ilstm_c[t]);

	ilstm_h[t]:ilstm_og[t]*ilstm_ct[t];
	ilstm_x[t]:xt;

	/ return h from this node 
	ilstm_h[t];

}





        
