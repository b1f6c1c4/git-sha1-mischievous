#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#=======================================================================
#
# sha1.py
# ---------
# Simple, pure Python model of the SHA-1 function. Used as a
# reference for the HW implementation. The code follows the structure
# of the HW implementation as much as possible.
#
#
# Author: Joachim Strömbergson
# (c) 2014 Secworks Sweden AB
# 
# Redistribution and use in source and binary forms, with or 
# without modification, are permitted provided that the following 
# conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer. 
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#    notice, this list of conditions and the following disclaimer in 
#    the documentation and/or other materials provided with the 
#    distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#=======================================================================

#-------------------------------------------------------------------
# Python module imports.
#-------------------------------------------------------------------
import sys


#-------------------------------------------------------------------
# Constants.
#-------------------------------------------------------------------


#-------------------------------------------------------------------
# ChaCha()
#-------------------------------------------------------------------
class SHA1():
    def __init__(self, verbose = 0):
        self.verbose = verbose
        self.H = [0] * 5
        self.t1 = 0
        self.t2 = 0
        self.a = 0
        self.b = 0
        self.c = 0
        self.d = 0
        self.e = 0
        self.f = 0
        self.g = 0
        self.h = 0
        self.w = 0
        self.W = [0] * 80
        self.k = 0
        self.K = [0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6d]
        
        
    def init(self):
        self.H = [0x67452301, 0xefcdab89, 0x98badcfe,
                  0x10325476, 0xc3d2e1f0]
        

    def next(self, block):
        self._W_schedule(block)
        self._copy_digest()
        if self.verbose:
            print("State after init:")
            self._print_state(0)

        for i in range(64):
            self._sha1_round(i)
            if self.verbose:
                self._print_state(i)

        self._update_digest()


    def get_digest(self):
        return self.H


    def _copy_digest(self):
        self.a = self.H[0] 
        self.b = self.H[1] 
        self.c = self.H[2] 
        self.d = self.H[3] 
        self.e = self.H[4] 
    
    
    def _update_digest(self):
        self.H[0] = (self.H[0] + self.a) & 0xffffffff 
        self.H[1] = (self.H[1] + self.b) & 0xffffffff 
        self.H[2] = (self.H[2] + self.c) & 0xffffffff 
        self.H[3] = (self.H[3] + self.d) & 0xffffffff 
        self.H[4] = (self.H[4] + self.e) & 0xffffffff 


    def _print_state(self, round):
        print("State at round 0x%02x:" % round)
        print("t1 = 0x%08x, t2 = 0x%08x" % (self.t1, self.t2))
        print("k  = 0x%08x, w  = 0x%08x" % (self.k, self.w))
        print("a  = 0x%08x, b  = 0x%08x" % (self.a, self.b))
        print("c  = 0x%08x, d  = 0x%08x" % (self.c, self.d))
        print("e  = 0x%08x" % (self.e))
        print("")


    def _sha1_round(self, round):
        self.k = self._next_k(round)
        self.w = self._next_w(round)
        self.t1 = self._T1(self.a, self.b, self.c, self.d, self.k, self.w)
        self.t2 = self._T2(self.a, self.b, self.c)
        self.e = (self.d + self.t1) & 0xffffffff
        self.d = self.c
        self.c = self.b
        self.b = self.a
        self.a = (self.t1 + self.t2) & 0xffffffff


    def _next_k(self, round):
        return 0xdeadbeef

    def _next_w(self, round):
        return 0xabcd0123

    def _W_schedule(self, block):
        for i in range(64):
            if (i < 16):
                self.W[i] = block[i]
            else:
                self.W[i] = (self._delta1(self.W[(i - 2)]) +
                             self.W[(i - 7)] + 
                             self._delta0(self.W[(i - 15)]) +
                             self.W[(i - 16)]) & 0xffffffff
        if (self.verbose):
            print("W after schedule:")
            for i in range(64):
                print("W[%02d] = 0x%08x" % (i, self.W[i]))
            print("")


    def _Ch(self, x, y, z):
        return (x & y) ^ (~x & z)


    def _Maj(self, x, y, z):
        return (x & y) ^ (x & z) ^ (y & z)

    def _sigma0(self, x):
        return (self._rotr32(x, 2) ^ self._rotr32(x, 13) ^ self._rotr32(x, 22))


    def _sigma1(self, x):
        return (self._rotr32(x, 6) ^ self._rotr32(x, 11) ^ self._rotr32(x, 25))


    def _delta0(self, x):
        return (self._rotr32(x, 7) ^ self._rotr32(x, 18) ^ self._shr32(x, 3))


    def _delta1(self, x):
        return (self._rotr32(x, 17) ^ self._rotr32(x, 19) ^ self._shr32(x, 10))
    

    def _T1(self, e, f, g, h, k, w):
        return (h + self._sigma1(e) + self._Ch(e, f, g) + k + w) & 0xffffffff


    def _T2(self, a, b, c):
        return (self._sigma0(a) + self._Maj(a, b, c)) & 0xffffffff


    def _rotr32(self, n, r):
        return ((n >> r) | (n << (32 - r))) & 0xffffffff

    
    def _shr32(self, n, r):
        return (n >> r)


def compare_digests(digest, expected):
    if (digest != expected):
        print("Error:")
        print("Got:")
        print(digest)
        print("Expected:")
        print(expected)
    else:
        print("Test case ok.")
        
    
#-------------------------------------------------------------------
# main()
#
# If executed tests the ChaCha class using known test vectors.
#-------------------------------------------------------------------
def main():
    print("Testing the SHA-256 Python model.")
    print("---------------------------------")
    print

    my_sha1 = SHA1(verbose=1);

    # TC1: NIST testcase with message "abc"
    TC1_block = [0x61626380, 0x00000000, 0x00000000, 0x00000000, 
                 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000018]
    
    TC1_expected = [0xBA7816BF, 0x8F01CFEA, 0x414140DE, 0x5DAE2223,
                    0xB00361A3, 0x96177A9C, 0xB410FF61, 0xF20015AD]
    
    my_sha1.init()
    my_sha1.next(TC1_block)
    my_digest = my_sha1.get_digest()
    compare_digests(my_digest, TC1_expected)

    

#-------------------------------------------------------------------
# __name__
# Python thingy which allows the file to be run standalone as
# well as parsed from within a Python interpreter.
#-------------------------------------------------------------------
if __name__=="__main__": 
    # Run the main function.
    sys.exit(main())

#=======================================================================
# EOF sha1.py
#=======================================================================