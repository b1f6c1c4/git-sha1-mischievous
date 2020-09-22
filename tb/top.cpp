#include <iostream>
#include <iomanip>
#include <string>
#include "Vsystem.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vsystem obj;
    obj.seed_i = 0x114514;
    obj.msg_i[15] = 0x00000000; obj.mask_i[15] = 0xf0000000;
    obj.msg_i[14] = 0x00000000; obj.mask_i[14] = 0x00000000;
    obj.msg_i[13] = 0x00000000; obj.mask_i[13] = 0x00000000;
    obj.msg_i[12] = 0x00000000; obj.mask_i[12] = 0x00000000;
    obj.msg_i[11] = 0x00000000; obj.mask_i[11] = 0x00000000;
    obj.msg_i[10] = 0x00000000; obj.mask_i[10] = 0x00000000;
    obj.msg_i[9]  = 0x00000000; obj.mask_i[9]  = 0x00000000;
    obj.msg_i[8]  = 0x00000000; obj.mask_i[8]  = 0x00000000;
    obj.msg_i[7]  = 0x00000000; obj.mask_i[7]  = 0x00000000;
    obj.msg_i[6]  = 0x00000000; obj.mask_i[6]  = 0x00000000;
    obj.msg_i[5]  = 0x00000000; obj.mask_i[5]  = 0x00000000;
    obj.msg_i[4]  = 0x00000000; obj.mask_i[4]  = 0x00000000;
    obj.msg_i[3]  = 0x00000000; obj.mask_i[3]  = 0x00000000;
    obj.msg_i[2]  = 0x00000000; obj.mask_i[2]  = 0x00000000;
    obj.msg_i[1]  = 0x00000000; obj.mask_i[1]  = 0x00000000;
    obj.msg_i[0]  = 0x00000000; obj.mask_i[0]  = 0x00000000;
    obj.dgst_i[4] = 0xda39a3ee;
    obj.dgst_i[3] = 0x5e6b4b0d;
    obj.dgst_i[2] = 0x3255bfef;
    obj.dgst_i[1] = 0x95601890;
    obj.dgst_i[0] = 0xafd80709;
    obj.reset_ni = 0;
    obj.clk_i = 1;
    obj.eval();
    obj.clk_i = 0;
    obj.eval();
    obj.clk_i = 1;
    obj.eval();
    obj.clk_i = 0;
    obj.reset_ni = 1;
    obj.eval();
    for (size_t t{ 0 }; t < 4096; t++) {
       obj.clk_i = 1;
       obj.eval();
       obj.clk_i = 0;
       obj.eval();
       std::cout << std::dec << obj.progress_o << " ";
       for (size_t i{ 0 }; i < 16; i++)
          std::cout << std::setfill('0') << std::setw(8) << std::right << std::hex << obj.msg_o[15 - i];
       std::cout << std::endl;
    }
}
