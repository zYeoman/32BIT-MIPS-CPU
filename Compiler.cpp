#include <iostream>
#include <fstream>
#include <string>

#define VERSION 0.1

using namespace std;

void showHelp(){
    cout<<"Usage: Compiler [Source] [Output]"<<endl;
    cout<<"Options:"<<endl;
    cout<<"    -h,--help     :  Show this help"<<endl;
    cout<<"    -v,--version  :  Show Version"<<endl;
}

int main(int argc, char const *argv[]){
    if (argc==1){
        showHelp();
    }
    else if(argc==2){
        string options=argv[1];
        if (options=="-h"||options=="--help"){
            showHelp();
        }
        else if(options=="-v"||options=="--version"){
            cout<<"Copyright (C) Yeoman Zhuang. All rights reserved."<<endl;
            cout<<"MIPS Compiler; from MIPS to HEX"<<endl;
            cout<<"Version: "<<VERSION<<endl;
        }
    }
    else if(argc>3){
        cerr<<"Error: Too many argument"<<endl;
    }
    else{
        ifstream sourceFile(argv[0]);
        ofstream outputFile(argv[1],ios::binary|ios::out);
        if (!sourceFile){
            cerr<<"Error: Can not open source file "<<argv[0]<<endl;
            return 1;
        }
        if (!outputFile){
            cerr<<"Error: Can not create output file "<<argv[1]<<endl;
            return 1;
        }
    }
    return 0;
}
