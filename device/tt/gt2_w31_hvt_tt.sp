/******************************************************************************/
/* BSD 3-Clause License
/*
/* Copyright 2025 Dongwon Jang, Nahid Shazon, Azad Naeemi, or Georgia Institute of Technology
/*
/* Redistribution and use in source and binary forms, with or without 
/* modification, are permitted provided that the following conditions are met:
/*
/* 1. Redistributions of source code must retain the above copyright notice, 
/* this list of conditions and the following disclaimer.
/*
/* 2. Redistributions in binary form must reproduce the above copyright notice, 
/* this list of conditions and the following disclaimer in the documentation 
/* and/or other materials provided with the distribution.
/*
/* 3. Neither the name of the copyright holder nor the names of its contributors 
/* may be used to endorse or promote products derived from this software without 
/* specific prior written permission.
/*
/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” 
/* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
/* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
/* ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
/* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
/* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
/* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
/* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
/* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
/* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
/******************************************************************************/


.LIB nfet_typ
.MODEL nmos NMOS l=1.4e-08
************************************************************
+delvtrand=-0.0578403
+ids0mult=1.0
+DEVTYPE=1
+EASUB=4.0727
+NI0SUB=1.1055e+16
+BG0SUB=1.1242
+NC0SUB=2.9951e+25
+eot=7e-10
+phig=4.34385
+RDSW=0
+RDSWMIN=0
+cdscd=0.021048
+vsat=200000
+VSAT1="10**4.43521"
+u0=0.00634578
+ua=0.452616
+PDIBL2="10**-10.3218"
+pclm=0.139454
+pclmg=6.14559e-09
+level=72
+VERSION=111
+BULKMOD=1
+CAPMOD=1
+IGCMOD=0
+IGBMOD=0
+GIDLMOD=0
+COREMOD=0
+GEOMOD=2
+CGEOMOD=0
+IIMOD=0
+RDSMOD=0
+tnom=25
+XL=0
+LINT=0
+LL=0
+LLC=0
+LLN=1
+dlc=-7.37013e-09
+tfin=5e-09
+hfin=3.100000e-08
+FPITCH=3e-08
+FECH=1
+NF=1
+NFIN=1
+NBODY=2e+20
+NSD=2e+26
+NGATE=0
+LPHIG=0
+LRDSW=0
+ARDSW=0
+BRDSW=1e-08
+PRWG=0
+CIT=0
+cdsc=0.0734236
+LCDSC=0
+LCDSCD=0
+DVT0=0
+LDVT0=0
+DVT1=0.7
+LDVT1=0
+PHIN=0
+LPHIN=0
+eta0=0
+LETA0=0
+DSUB=1.06
+LDSUB=0
+K1RSCE=0
+LK1RSCE=0
+LPE0=0
+LLPE0=0
+QMFACTOR=1
+qm0=4.3092
+LVSAT=0
+AVSAT=0
+BVSAT=6e-08
+AVSAT1=0
+BVSAT1=6e-08
+ksativ=0.807885
+LKSATIV=0
+DELTAVSAT=1
+MEXP="2+10**0.607671"
+LMEXP=0
+AMEXP=0
+BMEXP=1
+PTWG="10**0.620183"
+LPTWG=0
+APTWG=0
+BPTWG=6e-08
+LU0=0
+etamob=1.74175
+UP=0
+LUP=0
+LPA=1
+LUA=0
+AUA=0
+BUA=6e-08
+eu=1.43058
+LEU=0
+ud=0
+LUD=0
+AUD=0
+BUD=5e-08
+UCS=1
+LUCS=0
+PDIBL1=0
+LPDIBL1=0
+LPDIBL2=0
+DROUT=1.06
+LDROUT=0
+pvag=10.6892
+LPVAG=0
+LPCLM=0
+cfs=8.85553e-15
+PRWGS=1
+at=0
+cfd=8.85553e-15
+cgdl=1.26042e-10
+cgdo=0
+cgsl=1.26042e-10
+cgso=0
+ckappad=0.455693
+ckappas=0.455693
+delvfbacc=0
+dvtp0=-0.001
+dvtp1=1
+iit=0
+lsp=6e-09
+pqm=0.584323
+prt=0
+ptwgt=0
+qmtcencv=1.38198
+ua1=0
+uc1=0
+ucste=0
+utl=0

.ENDL nfet_typ


.LIB pfet_typ
.MODEL pmos PMOS l=1.4e-08
************************************************************
+delvtrand=-0.176689
+ids0mult=1.0
+DEVTYPE=0
+EASUB=4.0727
+NI0SUB=1.1055e+16
+BG0SUB=1.1242
+NC0SUB=2.9951e+25
+phig=4.95891
+eot=7e-10
+RDSW=0
+RDSWMIN=0
+cdscd=1e-12
+vsat=59626.8
+VSAT1="10**(4.25801)"
+u0=0.00844498
+ua=0.594108
+PDIBL2="10**-1.65661"
+pclm=0.0597687
+pclmg=0.109137
+CHARGEWF=0
+level=72
+VERSION=111
+BULKMOD=1
+CAPMOD=1
+IGCMOD=0
+IGBMOD=0
+GIDLMOD=0
+COREMOD=0
+GEOMOD=2
+CGEOMOD=0
+IIMOD=0
+RDSMOD=0
+tnom=25
+XL=0
+LINT=0
+LL=0
+LLC=0
+LLN=1
+dlc=-1.99536e-09
+tfin=5e-09
+hfin=3.100000e-08
+FPITCH=3e-08
+FECH=1
+NF=1
+NFIN=1
+NBODY=2e+20
+NSD=2e+26
+NGATE=0
+LPHIG=0
+LRDSW=0
+ARDSW=0
+BRDSW=1e-08
+PRWG=0
+CIT=0
+cdsc=0.203526
+LCDSC=0
+LCDSCD=0
+DVT0=0
+LDVT0=0
+DVT1=0.7
+LDVT1=0
+PHIN=0
+LPHIN=0
+eta0=0
+LETA0=0
+DSUB=1.06
+LDSUB=0
+K1RSCE=0
+LK1RSCE=0
+LPE0=0
+LLPE0=0
+QMFACTOR=1
+qm0=3.01004
+LVSAT=0
+AVSAT=0
+BVSAT=6e-08
+AVSAT1=0
+BVSAT1=6e-08
+ksativ=1.41461
+LKSATIV=0
+DELTAVSAT=1
+MEXP="2+10**0.245225"
+LMEXP=0
+AMEXP=0
+BMEXP=1
+PTWG="10**-4.99947"
+LPTWG=0
+APTWG=0
+BPTWG=6e-08
+LU0=0
+etamob=2.13416
+UP=0
+LUP=0
+LPA=1
+LUA=0
+AUA=0
+BUA=6e-08
+eu=0.768455
+LEU=0
+ud=0
+LUD=0
+AUD=0
+BUD=5e-08
+UCS=1
+LUCS=0
+PDIBL1=0
+LPDIBL1=0
+LPDIBL2=0
+DROUT=1.06
+LDROUT=0
+pvag=20.4259
+LPVAG=0
+LPCLM=0
+cfs=8.66296e-11
+PRWGS=1
+at=0
+cfd=8.66296e-11
+cgdl=7.80566e-11
+cgdo=0
+cgsl=7.80566e-11
+cgso=0
+ckappad=0.456192
+ckappas=0.456192
+delvfbacc=0
+dvtp0=-0.0132352
+dvtp1=1
+iit=0
+lsp=6e-09
+pqm=1.44665
+prt=0
+ptwgt=0
+qmtcencv=0.78297
+ua1=0
+uc1=0
+ucste=0
+utl=0

.ENDL pfet_typ
