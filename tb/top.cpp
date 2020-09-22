#include <iostream>
#include <iomanip>
#include <string>
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vtop obj;
    obj.clk_i = 1;
    obj.eval();
    obj.clk_i = 0;
    obj.block_i[0][0] = 0x00000020;
    obj.block_i[0][1] = 0x00000000;
    obj.block_i[0][2] = 0x00000000;
    obj.block_i[0][3] = 0x00000000;
    obj.block_i[0][4] = 0x00000000;
    obj.block_i[0][5] = 0x00000000;
    obj.block_i[0][6] = 0x00000000;
    obj.block_i[0][7] = 0x00000000;
    obj.block_i[0][8] = 0x00000000;
    obj.block_i[0][9] = 0x00000000;
    obj.block_i[0][10] = 0x00000000;
    obj.block_i[0][11] = 0x00000000;
    obj.block_i[0][12] = 0x00000000;
    obj.block_i[0][13] = 0x00000000;
    obj.block_i[0][14] = 0x80000000;
    obj.block_i[0][15] = 0x6675636b;
    obj.eval();
    for (size_t t{ 0 }; t < 256; t++) {
       obj.clk_i = 1;
       obj.eval();
       obj.clk_i = 0;
       obj.eval();
       std::cout << "t=" << t << " ";
       for (size_t i{ 0 }; i < 5; i++)
          std::cout << std::setfill('0') << std::setw(8) << std::right <<std::hex << obj.dgst_o[i];
       std::cout << std::endl;
    }
}
