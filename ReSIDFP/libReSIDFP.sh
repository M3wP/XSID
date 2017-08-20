g++ -m32 -std=c++11 -shared -I src -I src/resample -Wp,-DLIBRESIDFP_EXPORTS LibReSIDFP.cpp src/*.cpp src/resample/*.cpp -o ../libReSIDFP.so
