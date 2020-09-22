#include <iostream>
#include <iomanip>
#include <string>
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC tfp;
    Vtop obj;
    obj.trace(&tfp, 114514);
    tfp.open("build/dump.vcd");
    obj.block_i[0] = 0x00000020;
    obj.block_i[1] = 0x00000000;
    obj.block_i[2] = 0x00000000;
    obj.block_i[3] = 0x00000000;
    obj.block_i[4] = 0x00000000;
    obj.block_i[5] = 0x00000000;
    obj.block_i[6] = 0x00000000;
    obj.block_i[7] = 0x00000000;
    obj.block_i[8] = 0x00000000;
    obj.block_i[9] = 0x00000000;
    obj.block_i[10] = 0x00000000;
    obj.block_i[11] = 0x00000000;
    obj.block_i[12] = 0x00000000;
    obj.block_i[13] = 0x00000000;
    obj.block_i[14] = 0x80000000;
    obj.block_i[15] = 0x6675636b;
    obj.eval();
    for (size_t i{ 0 }; i < 5; i++)
       std::cout << std::setfill('0') << std::setw(8) << std::right <<std::hex << obj.dgst_o[i];
}
