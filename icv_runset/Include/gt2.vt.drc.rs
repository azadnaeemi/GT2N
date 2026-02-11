// BSD 3-Clause License
//
// Copyright 2025 Dongwon Jang, Piyush Kumar, Da Eun Shim, Azad Naeemi, or Georgia Institute of Technology
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, 
// this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation 
// and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



rELVT_1 @={ @ "ELVT.1 : Minimum vertical width of ELVT >= 72 nm";
        internal1( aELVT, distance < 0.072, extension = NONE, direction = VERTICAL);
}

rELVT_2 @={ @ "ELVT.2 : Minimum horizontal width of ELVT >= 14 nm";
        internal1( aELVT, distance < 0.014, extension = NONE, direction = HORIZONTAL);
}

rELVT_3 @={ @ "ELVT.3 : Minimum enclosure of ACT by ELVT in the vertical direction >= 15 nm";
        enclose( aACT, aELVT, distance < 0.015, extension = NONE, direction = VERTICAL);
}


rULVT_1 @={ @ "ULVT.1 : Minimum vertical width of ULVT >= 72 nm";
        internal1( aULVT, distance < 0.072, extension = NONE, direction = VERTICAL);
}

rULVT_2 @={ @ "ULVT.2 : Minimum horizontal width of ULVT >= 14 nm";
        internal1( aULVT, distance < 0.014, extension = NONE, direction = HORIZONTAL);
}

rULVT_3 @={ @ "ULVT.3 : Minimum enclosure of ACT by ULVT in the vertical direction >= 15 nm";
        enclose( aACT, aULVT, distance < 0.015, extension = NONE, direction = VERTICAL);
}


rSVT_1 @={ @ "SVT.1 : Minimum vertical width of SVT >= 72 nm";
        internal1( aSVT, distance < 0.072, extension = NONE, direction = VERTICAL);
}

rSVT_2 @={ @ "SVT.2 : Minimum horizontal width of SVT >= 14 nm";
        internal1( aSVT, distance < 0.014, extension = NONE, direction = HORIZONTAL);
}

rSVT_3 @={ @ "SVT.3 : Minimum enclosure of ACT by SVT in the vertical direction >= 15 nm";
        enclose( aACT, aSVT, distance < 0.015, extension = NONE, direction = VERTICAL);
}


rHVT_1 @={ @ "HVT.1 : Minimum vertical width of HVT >= 72 nm";
        internal1( aHVT, distance < 0.072, extension = NONE, direction = VERTICAL);
}

rHVT_2 @={ @ "HVT.2 : Minimum horizontal width of HVT >= 14 nm";
        internal1( aHVT, distance < 0.014, extension = NONE, direction = HORIZONTAL);
}

rHVT_3 @={ @ "HVT.3 : Minimum enclosure of ACT by HVT in the vertical direction >= 15 nm";
        enclose( aACT, aHVT, distance < 0.015, extension = NONE, direction = VERTICAL);
}


rSRAMVT_1 @={ @ "SRAMVT.1 : Minimum vertical width of SRAMVT >= 72 nm";
        internal1( aSRAMVT, distance < 0.072, extension = NONE, direction = VERTICAL);
}

rSRAMVT_2 @={ @ "SRAMVT.2 : Minimum horizontal width of SRAMVT >= 14 nm";
        internal1( aSRAMVT, distance < 0.014, extension = NONE, direction = HORIZONTAL);
}

rSRAMVT_3 @={ @ "SRAMVT.3 : Minimum enclosure of ACT by SRAMVT in the vertical direction >= 15 nm";
        enclose( aACT, aSRAMVT, distance < 0.015, extension = NONE, direction = VERTICAL);
}


rVT_OVERLAP_1 @= { @ "VT_OVERLAP.1 : VT layers (ELVT, ULVT, SVT, HVT, SRAMVT) should not overlap";
    interacting( aELVT, aULVT or aSVT or aHVT or aSRAMVT, include_touch = NONE) or
    interacting( aULVT, aSVT or aHVT or aSRAMVT, include_touch = NONE) or
    interacting( aSVT, aHVT or aSRAMVT, include_touch = NONE) or
    interacting( aHVT, aSRAMVT, include_touch = NONE);
}
