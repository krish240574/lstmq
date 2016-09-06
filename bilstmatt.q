nor:{$[x=2*n:x div 2;raze sqrt[-2*log n?1f]*/:(sin;cos)@\:(2*(acos -1))*n?1f;-1_.z.s 1+x]}
ng:{i:0;ll:();while[i<x;ll::ll,0.08 - (1?1000000)%1000000;i:i+1];(-1*ll)};
esz:50;
hsz:50; / esz = 10 also
isz:4; / vsz=4 also;osz = 4 also
/Gaussian, mean 0 stdev 0.1
gdist: (1.39960084e-02,  -4.35011689e-02,   1.28861498e-01, -3.46666164e-02,   1.34184231e-01,  -1.37983953e-02, -7.04530939e-02,   3.31049419e-02,  -7.56385373e-02, 9.63445486e-02,  -2.62203982e-02,   5.66919331e-02, -2.96467616e-02,   2.50835569e-03,   9.21534274e-03, 1.20644214e-01,  -8.82015157e-02,   1.01763790e-02, -1.54074688e-02,   5.37871217e-02,   7.75588166e-02, -8.14404895e-02,  -1.87196630e-01,   1.05153279e-01, -1.53083543e-01,  -7.04850346e-02,  -1.67310660e-01, 1.99012094e-01,  -2.41293930e-02,  -5.03968564e-02, 9.34688331e-02,  -3.64096162e-02,  -1.57576095e-01, -1.91541322e-01,  -6.72888600e-02,  -2.83752381e-02, -2.74142762e-02,   5.06991843e-02,   4.82176891e-02, -3.10553689e-02,   1.14132893e-01,  -1.66856248e-01, 8.38032017e-02,   6.83357714e-02,  -2.18264741e-01, -3.01702343e-02,  -5.51222149e-02,   1.98123082e-01, -5.75344516e-02,   9.65024352e-02,   8.98524631e-02, 7.36741309e-02,  -3.11941985e-02,   1.32154042e-01, -1.24627238e-01,  -3.50959065e-02,   6.58302864e-02, -2.59149230e-02,  -1.97294792e-02,   2.26600409e-02, 3.68270410e-03,   1.57842712e-01,  -2.73301145e-02, -1.61564278e-01,   3.44726856e-02,   1.08391208e-01, -1.08615699e-01,  -2.82599529e-02,   5.55074820e-03, -2.35857081e-02,  -4.29675724e-02,   3.61913584e-02, 1.58515082e-01,  -8.31720294e-02,   1.57284572e-01, -1.47342646e-01,   6.70725890e-02,  -1.31877081e-01, -1.12086312e-01,  -1.70073777e-01,  -5.24627840e-02, 8.10129622e-02,  -1.25662144e-01,   1.76347296e-01, -6.99645390e-02,  -9.12995173e-02,   1.58796505e-01, -1.64408670e-01,   3.57194356e-02,  -6.03721053e-02, 6.93244731e-02,   2.14772497e-03,   5.56335602e-02, 2.22997519e-01,  -2.00320617e-02,   3.80044479e-02, 5.26975653e-02,   2.32252266e-01,   7.94732922e-02, 4.69986016e-02,   2.58105334e-02,   1.32523511e-01, -7.30622281e-02,   1.16326781e-01,  -7.17246697e-02, -8.99071495e-02,  -5.93382794e-02,   1.02710720e-01, -9.11523877e-02,  -4.71328724e-02,   7.17323510e-02, 1.26891607e-01,  -5.28925628e-03,  -3.85274764e-04, 8.98746650e-02,  -1.70279126e-01,  -2.27886223e-02, 1.24026584e-02,   4.54057186e-02,   5.64318139e-02, -2.07864589e-01,  -4.03099633e-02,  -1.29362982e-01, 1.33247714e-01,   8.45921727e-02,  -1.04252693e-01, 1.73080272e-02,  -1.05315537e-01,   3.56437439e-02, 6.51209337e-02,   1.01474862e-01,  -1.96706234e-02, -1.39256756e-01,   9.51662091e-02,   1.09125334e-02, 1.57357036e-01,  -4.21034078e-02,  -8.26102132e-02, -1.54016042e-01,   2.85172250e-01,   4.11665710e-02, -3.28822572e-02,   8.07475341e-02,  -1.58711615e-01, 1.44879064e-01,  -1.69563238e-02,   1.69919767e-01, -9.80980752e-02,  -7.89973120e-03,  -7.30545161e-02, -7.39471878e-02,   2.75409113e-01,  -8.65250020e-02, -1.37032670e-02,   1.41164383e-01,   1.24061524e-01, -1.15423964e-01,   1.70517014e-02,   5.53294524e-02, 6.55089961e-02,   4.38529028e-02,  -6.00163678e-02, -3.52661106e-02,   2.18308669e-02,  -9.24817966e-02, 5.02945041e-02,   2.15950755e-03,  -1.17548849e-01, 1.53601722e-01,   1.86273347e-01,  -2.35801032e-01, 1.35320670e-01,  -1.94576894e-02,  -1.22332480e-02, -6.52631589e-02,   4.26149699e-02,  -1.41507487e-02, 6.86473299e-02,   1.54870559e-01,  -4.93946876e-02, -1.37573524e-01,   1.11830093e-01,   1.25340034e-01, 1.49239947e-01,  -4.22922781e-02,   2.03988641e-02, -1.44755051e-01,   2.06711643e-02,  -8.30030028e-03, -4.27360808e-02,   1.07357950e-01,  -5.89050365e-02, 8.68941175e-02,   2.12128409e-03,  -4.66738989e-02, -2.42284885e-02,  -7.79076683e-02,   1.51078892e-01, -2.22402685e-01,   5.38560263e-04,   5.71768892e-02, -2.01555326e-01,  -5.70321476e-02,  -8.86346240e-02, 1.56765541e-03,  -7.68877149e-03,   4.40593093e-02, -5.23801751e-02,   2.09969550e-02,   8.26874443e-02, 1.63741061e-01,   5.66621420e-02,  -3.60813559e-02, 8.87087382e-02,   3.93606550e-02,   4.63243840e-02, -9.84301454e-02,  -1.25127591e-01,   7.03115984e-02, 3.47603557e-02,   1.45892343e-01,   1.22331736e-02, 5.58733962e-04,  -5.23526902e-02,   1.03062481e-01, 3.29589019e-02,  -2.99404482e-02,  -7.56565754e-03, 2.95974878e-02,  -7.55092306e-02,  -1.46657403e-01, 9.11267037e-02,  -4.75870482e-02,   1.74682689e-01, -1.95615159e-03,  -1.15924218e-01,  -1.14327805e-01, -3.68474232e-02,  -6.42062820e-02,   1.58991253e-02, 1.09684456e-01,   1.37455245e-01,  -9.70103436e-02, 6.67276344e-02,  -3.13042409e-02,   1.69801052e-01, 6.41731193e-04,  -5.55987540e-02,  -3.50660367e-02, 5.46566592e-02,   1.38751948e-01,   6.46954950e-02, -9.36000118e-02,  -1.97380328e-02,  -5.51749139e-02, -1.37797609e-02,   7.66278107e-03,  -1.26218082e-02, -1.33106560e-01,  -6.12430707e-02,  -5.55671880e-02, -9.49911707e-02,  -3.84069876e-02,  -9.11254436e-02, 1.61107375e-01,   1.48268069e-01,  -1.01713825e-01, -1.05449411e-02,  -2.36015359e-02,   1.26434625e-02, -1.63751508e-02,   2.56315193e-01,   5.53640812e-02, 7.78353796e-02,   2.38563907e-01,  -7.81589944e-02, -8.00665038e-02,   1.90563275e-01,  -5.48889511e-02, 6.70348923e-02,   9.64286443e-02,  -1.76511877e-01, 2.51630961e-01,  -5.32505349e-02,  -3.24471895e-02, 1.04646963e-02,   1.30414282e-02,   1.14839744e-01, 8.96192781e-03,  -1.12974315e-01,  -3.44152326e-02, -1.11040759e-01,   1.68241785e-01,  -5.27902347e-02, 4.72054179e-02,   2.22417453e-01,  -1.00551824e-01, 6.86689728e-02,   2.90046118e-02,  -8.84745657e-02, 4.97438900e-02,  -1.44755217e-01,  -5.08904979e-02, -9.68330391e-02,  -9.38019279e-02,   7.61259844e-02, 1.52850756e-01,  -6.05694776e-02,   1.14708256e-01, -3.44036425e-02,  -7.13776171e-02,   5.52594449e-02, 9.61720030e-03,   7.37257514e-02,  -7.67748540e-02, -1.60369930e-02,   2.08640748e-01,  -6.01082605e-02, -1.31647973e-01,  -2.18387778e-01,   5.74732797e-02, -1.70217123e-01,  -9.03343838e-02,   1.08384316e-01, -2.25249551e-02,   3.46166753e-03,   3.73705863e-02, 4.05425152e-02,  -1.14999963e-01,   1.62007135e-01, -3.93116444e-02,   1.63857963e-01,  -5.13280995e-02, 9.34757626e-03,  -6.45629068e-02,   1.25827904e-01, -8.66201722e-02,  -1.80903347e-01,   2.82555875e-03, 7.37478149e-03,   1.21162256e-01,  -1.36326801e-01, 1.59760600e-01,   8.59524004e-02,   5.00933983e-02, -1.22721243e-01,  -8.03327944e-02,   3.22780109e-02, 8.68916319e-02,  -3.10201359e-02,  -8.23952343e-02, 8.85526840e-04,  -5.67062423e-06,  -2.76960268e-04, 1.01260428e-02,   3.14176679e-01,  -1.79555436e-01, -3.97158449e-02,   6.79031159e-02,  -6.74313805e-02, -5.81443735e-02,  -1.81364018e-02,  -2.31776173e-02, 9.55052718e-02,  -7.56175692e-02,   1.08175468e-01, 8.33172072e-02,  -1.66019831e-01,   9.86478068e-02, 1.69726272e-01,  -7.90818297e-02,   1.06879311e-01, 1.55032199e-01,  -5.46322937e-02,  -1.95467859e-02, 1.30020304e-01,   2.19233262e-01,  -1.08507294e-01, 2.48293936e-02,   2.89848065e-01,  -9.50357827e-02, -6.86827745e-02,  -1.61870617e-01,   1.39782619e-01, -6.56011753e-02,  -3.24510743e-02,   1.50362601e-01, 1.02700904e-01,  -2.05024389e-01,   1.59024098e-01, -6.41433521e-02,   1.98911690e-02,  -1.19230809e-02, -1.28181299e-01,  -6.06529022e-02,   7.33366014e-02, -9.79789077e-02,   5.28768279e-02,   5.02206839e-02, 1.48319099e-01,   7.14578557e-02,  -2.76273342e-02, -3.85434889e-02,   7.74929148e-02,   1.93266121e-01, -7.95763101e-02,   2.86435698e-02,   5.07227084e-02, -1.40091047e-01,   2.52148066e-02,   9.60340123e-02, 5.32985735e-02,   4.56624323e-02,  -2.55300859e-01, -7.82918577e-02,   1.07977518e-01,   5.42604255e-02, 6.95666687e-02,   2.12660328e-01,  -5.03332604e-02, 6.54784153e-02,  -2.69419987e-02,   6.45142970e-02, 8.77923423e-02,   2.41661473e-01,   1.75209750e-01, 6.51245339e-02,   3.99256533e-03,  -4.85645352e-02, 6.62551570e-02,   4.68782546e-02,   9.66445772e-02, -1.20059972e-01,  -2.12436365e-01,  -1.12333831e-01, -1.04022115e-01,  -1.12262131e-01,  -1.00486762e-01, -4.33589467e-02,   1.35087831e-03,  -2.24622701e-01, -1.44154613e-02,  -1.36527131e-02,  -4.61136286e-02, -1.05111296e-01,   3.49044122e-02,   2.85441188e-02, 2.49008651e-02,  -3.36177308e-02,  -8.83231513e-02, -2.31086791e-03,  -2.18920243e-01,  -2.09308821e-02, -3.33027320e-02,   4.38690978e-02,  -1.29383651e-01, 4.63675883e-02,  -1.28811548e-01,   9.06380867e-02, 6.41517689e-02,  -1.72701523e-01,  -3.23330669e-03, 5.61545190e-02,   9.44150517e-03,   1.94379341e-02, 9.94549124e-02,  -1.67739195e-01,   2.43494204e-02, -3.22227905e-02,   6.69417070e-02,  -3.83994656e-02, 4.82476874e-02,  -1.08976020e-02,   4.85071560e-02, -2.08207766e-01,  -1.01795605e-02,   9.87854600e-02, 8.69121933e-02,   1.37993056e-02,   7.24591102e-02, 1.66969334e-01,  -9.95977960e-03,   3.54840795e-02, 9.11929285e-02,   1.47420067e-01,  -7.14374585e-02, -5.60722619e-02,  -2.35279264e-02,   1.26999530e-01, -7.38686153e-02,  -3.42144731e-02,  -3.65390977e-03, 9.02354563e-03,  -2.11490994e-01,   7.11041937e-02, -8.56610456e-02,   8.64817144e-03,   8.51953333e-02, 1.12074395e-01,   1.38167847e-01,  -4.96563048e-02, -1.22271063e-01,  -4.86699775e-03,  -1.88704161e-02, -3.45823513e-02,  -2.99896447e-01,   5.53132644e-02, -1.16737027e-01,   1.72092047e-02,  -2.33587413e-02, -9.22030648e-02,  -1.99125079e-01,   4.01850861e-02, 1.32772998e-01,  -4.20008896e-02,  -3.66949261e-02, -5.67130119e-03,   4.27750160e-02,   3.41066442e-02, -2.83672129e-02,  -4.18598891e-02,  -1.06483151e-02, 2.64003899e-02,  -6.27011114e-03,  -7.35010203e-02, 5.66331185e-02,   1.77206547e-01,   5.81431997e-02, 5.86572054e-02,  -7.79057680e-02,  -2.70027722e-02, 5.51864733e-02,   1.24320851e-01,  -1.62216066e-01, 5.28879979e-02,   3.21865458e-02,  -1.07542020e-01, -2.51798306e-02,  -2.25640933e-02,  -2.02893465e-02, -1.18273005e-01,  -1.09289829e-01,  -4.06222211e-02, -4.63092382e-02,   1.38831778e-01,  -2.79629309e-02, -1.65383569e-02,   8.17392561e-02,  -3.87210122e-02, -2.77398300e-02,   6.72993039e-02,   4.45854507e-02, -6.48828322e-02,   3.80796233e-02,   1.35146453e-01, 1.15445202e-01,  -1.45521744e-01,   1.27844739e-01, 1.53115456e-01,  -3.25755046e-02,  -5.05606811e-04, -2.32413550e-02,   2.91445284e-02,  -2.23336140e-02, -3.23550543e-02,   6.39507872e-02,  -2.10537193e-02, 3.72447005e-02,   4.48872131e-02,  -8.58007450e-02, 6.01182281e-03,   1.40432949e-01,  -4.95279995e-02, 6.44043740e-02,   6.30308997e-02,  -1.78033813e-01, -3.47964292e-02,   1.81925704e-02,  -8.65259870e-02, 1.31893122e-01,  -9.47800924e-02,  -1.73934675e-01, -1.70122297e-01,  -7.21915187e-02,   5.31217574e-02, -8.47158696e-02,  -2.40537917e-02,  -1.15285415e-01, -8.38580418e-02,  -1.55294350e-01,  -1.93125464e-02, 8.70695185e-02,   1.95267244e-02,  -5.64362045e-02, -1.62120809e-01,   6.79375611e-02,  -1.28859304e-01, 2.63750803e-02,   6.64457304e-02,   1.44792516e-01, -5.53183116e-02,  -1.44420469e-01,   2.23973882e-02, -5.75308321e-02,  -3.59261105e-03,  -8.95703483e-02, 9.04385123e-03,  -2.92189862e-02,   1.78835046e-02, -4.99589361e-02,   6.17781187e-02,   1.91440436e-01, 4.29236180e-02,   3.01201926e-02,   1.23224381e-02, 8.41389521e-03,  -1.93285163e-01,   1.06702356e-01, -2.69690993e-02,   1.03739059e-01,  -9.28383995e-02, -3.84427110e-03,  -4.96952943e-03,  -3.72939139e-02, -5.91824961e-02,   1.64756381e-01,   6.49624807e-02, -2.00375222e-03,   1.37993437e-02,   1.21237709e-02, 2.60011925e-01,  -2.24079152e-03,   6.92492221e-02, -3.89771964e-04,   1.22649802e-01,  -3.44632949e-02, -9.09970777e-02,  -1.11545627e-01,   1.29929051e-01, 1.99437157e-02,  -2.72112059e-02,  -3.65330460e-01, 1.68270618e-01,  -5.77725530e-03,  -8.24143362e-02, -8.57725425e-02,  -6.02271634e-02,   2.87738828e-02, 2.16356728e-01,   7.67942006e-02,  -6.13535503e-03, -1.62916404e-01,   1.13697568e-01,   6.45514116e-02, -6.42487272e-02,   4.63866714e-02,  -9.65804792e-02, 7.87156701e-02,   9.23716898e-02,  -7.71856205e-02, 7.93983596e-02,   1.02499042e-01,   1.63332789e-02, 6.67601392e-02,  -4.46176201e-02,   1.33768512e-01, 7.84614295e-02,  -7.21035179e-02,  -6.59666954e-02, -1.35493110e-01,   9.85958289e-02,  -7.05911847e-02, -5.37272462e-03,   2.17192555e-02,  -1.17057072e-01, -7.03504702e-02,  -4.02407072e-02,  -6.02537978e-02, -1.11271295e-01,  -5.56486404e-02,   1.24091870e-02, 1.83899942e-01,  -4.51891088e-02,   8.39099859e-02, -1.30054601e-02,   2.05868983e-02,   1.09712892e-02, 1.06286966e-01,  -6.30971451e-02,  -4.05091346e-03, -5.90346486e-02,  -2.84278962e-03,   1.01992073e-01, 1.75003277e-01,  -3.48351256e-02,   9.60428369e-02, 5.11767621e-02,   5.91767483e-02,   1.11672579e-01, 9.94647091e-02,   2.44188715e-02,  -6.77087054e-02, 6.45022501e-02,  -4.38310768e-02,   9.47973557e-02, -2.66161597e-02,   9.07213036e-02,   1.13030382e-01, 2.78849648e-03,  -1.41614348e-02,  -6.58650231e-02, 1.71636990e-01,   1.04529301e-01,   1.23696795e-01, -1.38173579e-02,  -3.94176835e-02,   4.11689667e-03, -1.88704799e-01,  -3.27750396e-02,  -6.38153496e-02, -2.30170527e-02,   4.10568220e-02,   1.40042925e-01, -1.23273654e-02,   2.08355986e-02,   3.00862191e-02, 2.13042683e-01,   3.28138949e-02,  -1.50291284e-01, 9.23137493e-04,  -4.19839957e-02,  -8.03875883e-03, 7.97980676e-02,   1.54587717e-02,   4.45208353e-02, -5.93203353e-02,   1.10516977e-01,  -1.25807646e-01, -4.65468174e-02,   1.67172690e-02,  -8.10077687e-02, -5.65978175e-02,  -5.12633590e-02,   7.40552092e-02, -1.10878339e-01,  -7.44626912e-02,  -7.30677037e-02, -1.87201554e-01,   1.62359920e-01,  -1.16665143e-01, -7.38956595e-02,   9.44857338e-03,   1.10676222e-01, 1.97406428e-01,  -6.61586983e-02,  -2.35762619e-02, -2.26724564e-01,  -9.82385165e-02,   9.67202041e-02, 5.25038822e-02,  -1.19321536e-01,  -1.01709512e-01, 4.71739063e-03,   6.02682900e-02,  -1.88732595e-02, -4.46180475e-02,   3.86783650e-02,   1.58390345e-01, -3.99543128e-02,  -7.63227890e-02,   3.20225475e-02, 6.27861367e-02,   1.33750264e-02,   8.37255060e-02, -2.63538540e-01,   1.44046269e-01,   7.64169521e-02, -6.26193652e-02,   3.68608414e-02,   7.86592514e-02, 2.07063469e-01,  -2.01244458e-02,  -5.80311759e-02, 5.10124757e-02,   1.19455667e-01,  -5.64190488e-02, -5.33171809e-02,   9.11679638e-02,   2.19804983e-02, 1.34104553e-01,   1.21952828e-01,  -6.59623670e-02, -9.57180906e-02,   1.84166987e-02,   3.74179462e-02, -3.33984574e-02,   4.86923789e-02,   1.44889774e-02, -4.00840732e-02,  -5.42947655e-02,  -3.19326332e-02, 1.16149547e-01,   3.14221297e-02,  -4.00724432e-02, -2.42675007e-02,   1.38972315e-01,   7.13051776e-03, 2.62017175e-01,  -3.63311352e-02,   3.69886808e-02, 7.51020205e-02,   1.54723021e-01,  -6.22596908e-03, -4.09644154e-02,  -1.24578945e-01,   8.59515937e-02, 1.79730560e-02,   2.84924269e-03,   9.18251992e-02, -1.14642055e-01,  -4.48740278e-02,  -1.20802330e-01, 1.00341598e-01,  -3.65637186e-02,  -1.30397513e-01, -1.09232372e-01,  -4.29269138e-02,  -1.40423576e-01, 2.03804716e-02,   9.83052953e-02,  -1.02224306e-01, -1.05791304e-01,   2.97761952e-02,  -7.44158284e-02, 1.56940311e-01,   1.48095745e-01,  -2.29650987e-02, -1.45920137e-02,  -1.32714775e-01,  -1.89551494e-02, 2.85653759e-03,   6.12925519e-02,   1.48319011e-01, 1.01613312e-01,  -6.26265132e-02,  -2.29779750e-03, -2.15464482e-01,   4.47273945e-02,   1.36827194e-01, -2.10639727e-02,   8.54349199e-02,   1.68541437e-01, -1.76665435e-02,   8.90972060e-02,  -5.36231296e-02, 3.19329902e-02,  -1.22496172e-01,   3.81157787e-02, 1.12130915e-02,  -5.69644960e-02,  -6.49441767e-02, 1.12865945e-01,  -4.11960844e-03,  -6.05091849e-02, 6.98180730e-03,  -5.31748219e-02,   3.18925807e-04, -1.05908655e-01,   6.37190480e-02,  -1.96462579e-01, -3.15063578e-02,   1.62322989e-01,  -6.13604282e-02, 8.16899204e-02,  -1.68408415e-02,  -5.48970193e-02, 5.47792927e-03,  -1.62267969e-02,   2.67209595e-01, 1.27604061e-01,  -2.19589306e-02,  -9.21072891e-03, -5.21306959e-02,   3.41310765e-02,   6.08477722e-02, 8.54095227e-02,   1.10231594e-01,  -4.01130031e-02, -3.55567966e-02,   3.96796744e-02,  -1.26346177e-01, 2.54357486e-01,   9.70169823e-02,   1.57663380e-02, -1.05294581e-01,  -1.37576960e-01,   3.48744553e-02, -1.08001021e-01,   4.03949942e-02,  -7.76294632e-02, -1.45883444e-02,  -2.62125875e-02,   3.06939506e-03, 1.72273344e-01,   1.87263315e-02,  -1.33490114e-01, 9.56509999e-02,  -3.07474555e-01,  -1.34369964e-01, -8.25414214e-02,   2.68231135e-02,  -3.00037196e-02, 1.95057157e-02,   6.65115627e-02,   1.43483345e-01, 1.20587183e-01,  -5.21305352e-02,  -3.22035932e-02, 4.42521264e-02,  -4.79235153e-04,  -4.39003101e-03, 8.35453553e-02,  -1.76866750e-01,   1.16482946e-01, 6.94897407e-02,   1.14289548e-02,   1.61693662e-01, -7.97379482e-02,  -4.05535400e-02,  -7.61578728e-02, 1.74532298e-01,  -4.29388932e-02,  -4.51318790e-02, -1.25088351e-02,  -1.45540841e-01,   7.50904026e-02, 1.87588855e-01,   1.18307775e-01,   1.45099261e-01, -1.99244997e-02,   6.86376979e-02,  -2.61544837e-02, -7.45895730e-02,   4.19149844e-02,   4.90247994e-02, 4.29324134e-02,  -1.37812890e-01,  -1.95207898e-01, -8.63259943e-02,   4.48902257e-02,   1.23521875e-01, 6.45800149e-02,  -2.99762888e-02,  -2.69558713e-01, 4.08123060e-02,  -1.88654734e-01,  -1.28525839e-01, 3.58700464e-02,   1.38872444e-01,  -2.35902126e-03, 2.80389703e-02,   2.70375212e-02,  -7.59774061e-02, 8.25044097e-02,  -1.59849824e-01,   4.49805402e-02, -6.16453251e-02,   4.13220328e-02,   6.34877330e-02, 1.45029649e-01,  -8.29433310e-02,   9.97417337e-03, -9.59473136e-02,  -8.17943027e-02,  -1.55273876e-01, -5.67635034e-02,  -7.75409309e-02,   5.19920201e-02, -1.28673918e-01,  -2.71733477e-02,   1.93980224e-02, 1.14717710e-01,  -2.35318347e-02,   1.77698218e-01, 7.11036467e-02,   1.48073979e-01,   3.45213391e-02, 1.42726442e-01,  -5.60882099e-02,  -2.42402262e-01, -2.41056946e-01,  -5.80177040e-02,   6.90484182e-02, -1.13638068e-02,   5.69824104e-02,   1.73620544e-02, 8.92258013e-02,  -1.27614057e-01,  -1.25435079e-01, -1.45967786e-01);

master:til count gdist;data:gdist;flist:(); /vars for sampler
sampler:{[master;c]while[c>count flist;
	smpl:distinct (floor (count master)%(2))?(master);
	$[0=count flist;
		flist::data[smpl];
		flist::flist,data[smpl]];
	m:master[where not master in smpl]];
	:flist[til c]
 }

/Embedding
embw:(2,isz,hsz)#sampler[master;1000]; /2,vsz,esz
embdw:(2,isz,hsz)#0.0; /2,vsz,esz
et:(0;0); / time pointer in embedding
embx:(2 1)#(); 
/ LSTM
Lo:(1,isz)#0
Lwo:((2,hsz,hsz)#sampler[master;1000]); / weights from forward to output and backward to output
Lwh:((2,hsz,hsz)#sampler[master;1000];(2,hsz,hsz)#sampler[master;1000];(2,hsz,hsz)#sampler[master;1000];(2,hsz,hsz)#sampler[master;1000]); /i,f,o,j
Lwx:((2,hsz,esz)#sampler[master;1000];(2,hsz,esz)#sampler[master;1000];(2,hsz,esz)#sampler[master;1000];(2,hsz,esz)#sampler[master;1000]);
Lb:((2,hsz)#0f;(2,hsz)#0f;(2,hsz)#0f;3*(2,hsz)#1f); / bi;bf;bo;bj
Ldb:((2,hsz)#0f;(2,hsz)#0f;(2,hsz)#0f;(2,hsz)#0f); / bi;bf;bo;bj
Ldwx:((2,hsz,esz)#0f;(2,hsz,esz)#0f;(2,hsz,esz)#0f;(2,hsz,esz)#0f); 
Ldwh:((2,hsz,hsz)#0f;(2,hsz,hsz)#0f;(2,hsz,hsz)#0f;(2,hsz,hsz)#0f);
LSTMx:(2 1)#"0";
LSTMt:(0;0); / time pointer in LSTM
lstmH:(2,1,hsz)#0;
lstmC:(2,1,hsz)#0;
lstmCt:(2 1)#"0";
/all gates here
lstmIg:(2 1)#"0"; / 2 rows, one for input and one for output
lstmFg:(2 1)#"0";
lstmOg:(2 1)#"0";
lstmCupd:(2 1)#"0";
Ldhprev:(2,1,hsz)#0;
Ldcprev:(2,1,hsz)#0;
annot:();

/ Softmax variables
smpreds:();
smx:();
smtargets:();
smt:0;
smw:(2,isz,hsz)#sampler[master;1000]; /osz,hsz - 2 sets of weights, one from fw and bw lstm resp.
smdw:(isz,hsz)#0; /osz,hsz


/ input forward - embedding, then lstm
ifw:{[iseq;t]L:0;
	/show "IFProp"; 
	h:embfw[L;iseq[t]];
	h:LSTMfw[L;h];
	$[t<(-1+count iseq);ifw[iseq;t+1];h]
 }

embfw:{[L;i]
	$[0=count embx[L;0];embx[L;0]::enlist i;embx[L]::(embx[L], enlist i)];
	et[L]::et[L]+1;
	embw[L;i]
 }
ac:-1;
encoderfw:{[L;xt]FW:0;BW:1;

	/-----------Forward LSTM FP--------------------/

	L:FW;
	LSTMt[L]::LSTMt[L]+1;
	t:LSTMt[L];
	ac::ac+1;
	h:"f"$lstmH[L;t-1];

	k:(1%1+exp(-1*((Lwh[0;L]$h)+(Lwx[0;L]$xt)+Lb[0;L])));
	lstmIg[L]::(lstmIg[L], enlist k);

	k:(1%1+exp(-1*((Lwh[1;L]$h)+(Lwx[1;L]$xt)+Lb[1;L])));
	lstmFg[L]::(lstmFg[L], enlist k);

	k:(1%1+exp(-1*((Lwh[2;L]$h)+(Lwx[2;L]$xt)+Lb[2;L])));
	lstmOg[L]::(lstmOg[L], enlist k);

	tmp:(Lwh[3;L]$h)+(Lwx[3;L]$xt)+Lb[3;L];
	k:((exp(tmp)-exp(-1*tmp)))%((exp(tmp)+exp(-1*tmp)));
	lstmCupd[L]::(lstmCupd[L], enlist k);

	tmp:(raze lstmIg[L;t]*lstmCupd[L;t])+(raze lstmFg[L;t])*lstmC[L;t-1];
	lstmC[L]::(lstmC[L], enlist tmp);

	tmp:((exp(tmp)-exp(-1*tmp)))%((exp(tmp)+exp(-1*tmp)));
	lstmCt[L]::(lstmCt[L], enlist tmp);

	tmp:lstmOg[L;t]*lstmCt[L;t];
	lstmH[L]::(lstmH[L], enlist tmp);

	LSTMx[L]::(LSTMx[L], enlist xt);

	$[0=count annot;annot[ac]::lstmH[L;ac];annot[ac]::annot[ac],enlist(lstmH[L;ac])];

	/-----------Reverse LSTM FP--------------------/
	L:BW;
	LSTMt[L]::LSTMt[L]-1;
	t:LSTMt[L];

	h:"f"$lstmH[L;t+1];

	k:(1%1+exp(-1*((Lwh[0;L]$h)+(Lwx[0;L]$xt)+Lb[0;L])));
	lstmIg[L]::(lstmIg[L], enlist k);

	k:(1%1+exp(-1*((Lwh[1;L]$h)+(Lwx[1;L]$xt)+Lb[1;L])));
	lstmFg[L]::(lstmFg[L], enlist k);

	k:(1%1+exp(-1*((Lwh[2;L]$h)+(Lwx[2;L]$xt)+Lb[2;L])));
	lstmOg[L]::(lstmOg[L], enlist k);

	tmp:(Lwh[3;L]$h)+(Lwx[3;L]$xt)+Lb[3;L];
	k:((exp(tmp)-exp(-1*tmp)))%((exp(tmp)+exp(-1*tmp)));
	lstmCupd[L]::(lstmCupd[L], enlist k);	

	tmp:(raze lstmIg[L;t]*lstmCupd[L;t])+(raze lstmFg[L;t])*lstmC[L;t+1];
	lstmC[L]::(lstmC[L], enlist tmp);

	tmp:((exp(tmp)-exp(-1*tmp)))%((exp(tmp)+exp(-1*tmp)));
	lstmCt[L]::(lstmCt[L], enlist tmp);

	tmp:lstmOg[L;t]*lstmCt[L;t];
	lstmH[L]::(lstmH[L], enlist tmp);

	LSTMx[L]::(LSTMx[L], enlist xt);

	annot[ac]::annot[ac],enlist(lstmH[L;ac]);
 }


 decoderFw:{[L;xt]FW:0;BW:1;
	DCDR:2;

	L:DCDR;

	lstmH[L;0]::lstmH[FW;LSTMt[FW]],lstmH[BW, LSTMt[BW]]; 
	lstmC[L;0]::lstmC[FW;LSTMt[FW]],lstmC[BW;LSTMt[BW]]; 

	LSTMt[L]::LSTMt[L]+1;
	t:LSTMt[L];

	h:"f"$lstmH[L;t-1];

	k:(1%1+exp(-1*((Lwh[0;L]$h)+(Lwx[0;L]$xt)+Lb[0;L])));
	lstmIg[L]::(lstmIg[L], enlist k);

	k:(1%1+exp(-1*((Lwh[1;L]$h)+(Lwx[1;L]$xt)+Lb[1;L])));
	lstmFg[L]::(lstmFg[L], enlist k);

	k:(1%1+exp(-1*((Lwh[2;L]$h)+(Lwx[2;L]$xt)+Lb[2;L])));
	lstmOg[L]::(lstmOg[L], enlist k);

	tmp:(Lwh[3;L]$h)+(Lwx[3;L]$xt)+Lb[3;L];
	k:((exp(tmp)-exp(-1*tmp)))%((exp(tmp)+exp(-1*tmp)));
	lstmCupd[L]::(lstmCupd[L], enlist k);

	tmp:(raze lstmIg[L;t]*lstmCupd[L;t])+(raze lstmFg[L;t])*lstmC[L;t-1];
	lstmC[L]::(lstmC[L], enlist tmp);

	tmp:((exp(tmp)-exp(-1*tmp)))%((exp(tmp)+exp(-1*tmp)));
	lstmCt[L]::(lstmCt[L], enlist tmp);

	tmp:lstmOg[L;t]*lstmCt[L;t];
	lstmH[L]::(lstmH[L], enlist tmp);

	LSTMx[L]::(LSTMx[L], enlist xt);

	:lstmH[L;t] 
 }

 softmaxfw:{[ix]smt::smt+1;
	yy:smw$ix;
	yy:exp(yy-max yy);
	yy:yy%sum yy;
	$[0=count smpreds;smpreds::(1,isz)#yy;smpreds::(smpreds, enlist yy)];
	$[0=count smx;smx::(1,hsz)#ix;smx::(smx, enlist ix)];
	yy
 }

 embfw:{[L;i]
	$[0=count embx[L;0];embx[L;0]::enlist i;embx[L]::(embx[L], enlist i)];
	et[L]::et[L]+1;
	embw[L;i]
 }
encoder:{[iseq]
	encoderfw[iseq];
}
/ https://indico.io/blog/wp-content/uploads/2016/04/figure1.jpeg
decoder:{[oSeq]
	lstmH[DCDR;0]:(lstmH[FW;LSTMt[FW],lstmH[BW;LSTMt[BW]]); 
	lstmC[DCDR;0]:(lstmC[FW;LSTMt[FW],lstmC[BW;LSTMt[BW]]); 
	t:0;
	while[t<count oSeq;
	if[t=0;sPrev:lstmH[DCDR;0];cPrev:lstmC[DCDR;0]]; 
	if[t>0;sPrev:lstmH[DCDR;t-1];cPrev:lstmC[DCDR;t-1]];
	alphasT:mlpFw[sPrev,cPrev];
	ctx:+/alphasT*annot;
	xT:embFW[DCDR;oSeq[t]];
	h:decoderFw[DCDR;(xT,ctx)];
	softmaxfw[h];
	t:t+1]
	}

 mlpFw:{[decoderstate]
 	/ for state of LSTM decoder and entire annotation vector, compute alphas
 	annot:(lstmH[FW;],lstmH[BW;]);
 	szMlpInputs:count(decoderState,annot)[0]);
 	i:0;
 	mlpIB:0.0;
 	mlpHB:0.0;
 	mlpWO:((szMlpInputs),1)#(sampler[master;1000]);
 	mlpW:(szMlpInputs,szMlpInputs)#(sampler[master;1000]);
 	while[i<(count annot);
		mlpInputs:(decoderState,annot[i]);
    	mlpIX:(1,count mlpInputs[0])#mlpInputs;
    	mlpHid:(1,count mlpInputs[0])#0;
		mlpHid:mlpIB+mlpW$mlpIX; 
		output:mlpHB+mlpHid$mlpWO;
		$[0=count mlpO:mlpO:output;mlpO:mlpO,enlist output]
 		i:i+1;
 	];
	alphas:(mlpO%sum mlpO);
	:alphas
 }


 encoderbw:{[L;dh]FW:0;BW:0;

	/ Backward LSTM first
	L:BW;
	DCDR:2;
	Ldhprev[L]::Ldhprev[DCDR];Ldcprev[L]::Ldcprev[DCDR];

	t:LSTMt[L];
	tdh:dh;
	dh:tdh+raze Ldhprev[L]; 

	tmp:lstmCt[L;t]; 
	dC:((1-tmp*tmp)*lstmOg[L;t]*dh)+raze Ldcprev[L]; 

	tmp:lstmIg[L;t]; 
	dinput:(tmp*(1-tmp))*lstmCupd[L;t]*dC; 

	tmp:lstmFg[L;t]; 
	dforget:(tmp*(1-tmp))*lstmC[L;t+1]*dC; 

	tmp:lstmOg[L;t]; 
	doutput:(tmp*(1-tmp))*lstmCt[L;t]*dh; 

	tmp:lstmCupd[L;t]; 
	dupdate:(1-tmp*tmp)*lstmIg[L;t]*dC; 

	Ldcprev[L]::lstmFg[L;t]*dC; 

	Ldb[0;L]::Ldb[0;L]+dinput;
	Ldb[1;L]::Ldb[1;L]+dforget;
	Ldb[2;L]::Ldb[2;L]+doutput; 
	Ldb[3;L]::Ldb[3;L]+dupdate; 

	hin:lstmH[L;t+1]; 
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
	LSTMt[L]::LSTMt[L]+1;
	:dX 

	/------------------------
	L:FW;
	Ldhprev[L]::Ldhprev[DCDR];Ldcprev[L]::Ldcprev[DCDR];

	t:LSTMt[L];

	dh:tdh+raze Ldhprev[L]; 

	tmp:lstmCt[L;t]; 
	dC:((1-tmp*tmp)*lstmOg[L;t]*dh)+raze Ldcprev[L]; 

	tmp:lstmIg[L;t]; 
	dinput:(tmp*(1-tmp))*lstmCupd[L;t]*dC; 

	tmp:lstmFg[L;t]; 
	dforget:(tmp*(1-tmp))*lstmC[L;t-1]*dC; 

	tmp:lstmOg[L;t]; 
	doutput:(tmp*(1-tmp))*lstmCt[L;t]*dh; 

	tmp:lstmCupd[L;t]; 
	dupdate:(1-tmp*tmp)*lstmIg[L;t]*dC; 

	Ldcprev[L]::lstmFg[L;t]*dC; 

	Ldb[0;L]::Ldb[0;L]+dinput;
	Ldb[1;L]::Ldb[1;L]+dforget;
	Ldb[2;L]::Ldb[2;L]+doutput; 
	Ldb[3;L]::Ldb[3;L]+dupdate; 

	hin:lstmH[L;t-1]; 
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
 };


 decoderbw:{

 	DCRD:2;
 	L:DCDR;
	t:LSTMt[L];

	dh:tdh+raze Ldhprev[L]; 

	tmp:lstmCt[L;t]; 
	dC:((1-tmp*tmp)*lstmOg[L;t]*dh)+raze Ldcprev[L]; 

	tmp:lstmIg[L;t]; 
	dinput:(tmp*(1-tmp))*lstmCupd[L;t]*dC; 

	tmp:lstmFg[L;t]; 
	dforget:(tmp*(1-tmp))*lstmC[L;t-1]*dC; 

	tmp:lstmOg[L;t]; 
	doutput:(tmp*(1-tmp))*lstmCt[L;t]*dh; 

	tmp:lstmCupd[L;t]; 
	dupdate:(1-tmp*tmp)*lstmIg[L;t]*dC; 

	Ldcprev[L]::lstmFg[L;t]*dC; 

	/Ldb::Ldb+((dinput;dforget;doutput;dupdate))
	Ldb[0;L]::Ldb[0;L]+dinput;
	Ldb[1;L]::Ldb[1;L]+dforget;
	Ldb[2;L]::Ldb[2;L]+doutput; 
	Ldb[3;L]::Ldb[3;L]+dupdate; 

	hin:lstmH[L;t-1]; 
	/Ldwx::Ldwx+((dinput*/:LSTMx[L;t]);(dforget*/:LSTMx[L;t]);(doutput*/:LSTMx[L;t]);(dupdate*/:LSTMx[L;t]))
	Ldwx[0;L]::Ldwx[0;L]+(dinput*/:LSTMx[L;t]); 
	Ldwx[1;L]::Ldwx[1;L]+(dforget*/:LSTMx[L;t]);
	Ldwx[2;L]::Ldwx[2;L]+(doutput*/:LSTMx[L;t]); 
	Ldwx[3;L]::Ldwx[3;L]+(dupdate*/:LSTMx[L;t]);
	
	/Ldwh::Ldwh+((dinput*/:lstmH[L;t]);(dforget*/:lstmH[L;t]);(doutput*/:lstmH[L;t]);(dupdate*/:lstmH[L;t]))
	Ldwh[0;L]::Ldwh[0;L]+(dinput*/:hin);
	Ldwh[1;L]::Ldwh[1;L]+(dforget*/:hin);
	Ldwh[2;L]::Ldwh[2;L]+(doutput*/:hin);
	Ldwh[3;L]::Ldwh[3;L]+(dupdate*/:hin);

	/Ldhprev[L]::((flip Lwh[0;L])$dinput) + ((flip Lwh[1;L])$dforget) + ((flip Lwh[2;L])$doutput) + ((flip Lwh[3;L])$dupdate);
	/Ldhprev[L]::(flip Lwh[0;L];flip Lwh[1;L];flip Lwh[2;L];flip Lwh[3;L])$(4 1)#(dinput;dforget;doutput;dupdate)
	Ldhprev[L]::((flip Lwh[0;L])$dinput);
	Ldhprev[L]::Ldhprev[L]+((flip Lwh[1;L])$dforget);
	Ldhprev[L]::Ldhprev[L]+((flip Lwh[2;L])$doutput);
	Ldhprev[L]::Ldhprev[L]+((flip Lwh[3;L])$dupdate);

	/dX::(flip Lwx[0;L];flip Lwx[1;L];flip Lwx[2;L];flip Lwx[3;L])$(4 1)#(dinput;dforget;doutput;dupdate)
	dX:(flip Lwx[0;L])$dinput;
	dX:dX+(flip Lwx[1;L])$dforget;
	dX:dX+(flip Lwx[2;L])$doutput;
	dX:dX+(flip Lwx[3;L])$dupdate;
	LSTMt[L]::LSTMt[L]-1;
 }





/ Output layers - backward pass now.
/ Reverse the output sequence
obw:{[oseq;c]L:1;
	/show "OBProp";
	dh:raze softmaxbw[oseq[c]];
	dh:LSTMbw[L;dh];
	dh:embbw[L;dh];
	$[c<(-1+count oseq);obw[oseq;c+1];dh]
 }

softmaxbw:{[i]smt::smt-1;
	$[0=count smtargets;smtargets::i;smtargets::(smtargets, enlist i)];
	tmpx:raze over ((hsz,1)#smx[smt]);
	tmpd:raze over ((1,isz)#smpreds[smt]);
	tmpd[i]:tmpd[i]-1;
	smdw::smdw+flip (tmpd*/:tmpx);
	delta:(1,hsz)#(flip smw)$tmpd; 
	:delta
 }


embbw:{[L;delta]et[L]::et[L]-1;	tx:raze embx[L];tx:tx[et[L]];embdw[L;tx]::embdw[L;tx]+delta}


/input backward pass
ibw:{[iseq;c]L:0;
	/show "IBProp";
	delta:raze (1,hsz)#0;
	delta:LSTMbw[L;delta];
	delta:embbw[L;delta];
	$[c<(-1+count iseq);ibw[iseq;c+1];delta]
 }

clipgrad:5.0;
lr:0.00001;
normalizegrads:{[n]Ldwx::Ldwx%n;Ldwh::Ldwh%n;embdw::embdw%n;smdw::smdw%n};
takestep:{[lr]Lwx::Lwx-lr*Ldwx;Lwh::Lwh-lr*Ldwh;Lb::Lb-lr*Ldb;embw::embw-lr*embdw;smw::smw-lr*smdw};

/ Get cost for this training run
getCost:{[dummy]sum {-1*log((smpreds[x])[smtargets[x]])}each til count smtargets};

initLayer:{[L]
	/show "Init layer:";
	/show L;
	embdw[L]::(isz,hsz)#0.0; 
	et[L]::0; 
	embx[L]::enlist (); 

	LSTMt[FW]::0;
	LSTMt[BW]::nRows; / size of input dataset
	LSTMx[L]::"0";
	lstmH[L]::(1,hsz)#0;
	lstmC[L]::(1,hsz)#0;
	lstmCt[L]::"0";

	lstmIg[L]::"0"; 
	lstmFg[L]::"0";
	lstmOg[L]::"0";
	lstmCupd[L]::"0";

	Ldhprev[L]::(1,hsz)#0;
	Ldcprev[L]::(1,hsz)#0;
	FW:0;
	BW:1;

	/ important note - the lstmH list for the backward LSTM grows in reverse - but is numbered normally, i.e 0,1,2,3...
	/  It should be read as follows - 0 - last entry, 1, second last, 2, third last and so on...
	/ same goes for the Ldhprev and Ldcprev lists too.

	/if[L=BW;lstmH[L;0]::lstmH[FW;LSTMt[FW]];lstmC[L;0]::lstmC[FW;LSTMt[FW]]];
	/if[L=FW;Ldhprev[L]::Ldhprev[BW];Ldcprev[L]::Ldcprev[BW]];

	Ldb[;L;]::0.0;
	Ldwx[;L;;]::0.0;
	Ldwh[;L;;]::0.0;

	if[L=BW;
		smpreds::();
		smx::();
		smtargets::();
		smt::0;
		smdw::(isz,hsz)#0f]; /osz,hsz
	}
train:{[iseq;oseq]L:0;
	initLayer[L];
	/  Forward
	ifw[iseq;0];
	L:1;
	initLayer[L];
	ofw[(0;oseq);0];
	/  Backward
	obw[reverse(oseq;0);0];
	ibw[reverse(iseq);0];
	gradnorm: sqrt((sum over Ldwx xexp 2)+(sum over Ldwh xexp 2) +(sum over embdw xexp 2)+(sum over smdw xexp 2));
	if[gradnorm>clipgrad;normalizegrads(gradnorm%clipgrad)];
	takestep[lr];
	:getCost[-1]
 }
EOS:0;
maxl:10;
applyoutputmodel:{[prediction;token]
	tmp:token;
	tmp:ofw[(enlist tmp);0];
	token:sum where tmp = (max tmp);
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
	:prediction
 }


mainp:{[counter]
	while[counter < 100000;
	cost:train[(2;1);2];
	/ show "cost1:";
	/ show cost;
	cost:cost+train[enlist (1);1];
	/ show "cost2:";
	/ show cost;
	/ cost:cost+train[(3;1);3];
	/ show "cost3:";
	/show cost;
	if[0 = (counter mod 100);
		show "Epoch:";
		show counter;
		show "Training cost:";
		show cost%2;	
		show "Predicting for [2,1] -> ";
		show predict[(2;1)];
		show "Predicting for [1] -> ";
		show predict[enlist (1)];
		/ show "Predicting for [3,1] -> ";
		/ show predict[(3;1)];
		show "---------------";];
		counter:counter+1;]
		 }

mainp[0]; 

/ initLayer[0];
/ ifw[(2;1);0];
/ initLayer[1];
/ ofw[(0;2);0];

/ obw[reverse(2;0);0];
/ ibw[reverse(2;1);0];
/ gradnorm: sqrt((sum over Ldwx xexp 2)+(sum over Ldwh xexp 2) +(sum over embdw xexp 2)+(sum over smdw xexp 2));





