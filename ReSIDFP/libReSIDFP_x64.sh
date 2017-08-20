g++ -fPIC -shared -std=c++11 -I src -I src/resample -Wp,-DLIBRESIDFP_EXPORTS LibReSIDFP.cpp src/*.cpp src/resample/*.cpp -o ../libReSIDFP.so
