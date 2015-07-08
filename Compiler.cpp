/*
Filename : Compiler.cpp
Compiler : Visual Studio 2013
Description : Trans MIPS to HEX
Release : 7/10/2015
*/

#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#define VERSION 0.2

using namespace std;

void showHelp(){
    cout<<"Usage: Compiler [Source] [Output]"<<endl;
    cout<<"Options:"<<endl;
    cout<<"    -h,--help     :  Show this help"<<endl;
    cout<<"    -v,--version  :  Show Version"<<endl;
}

string& trim(string &s){
	if (s.empty()){
		return s;
	}

	s.erase(0, s.find_first_not_of(" "));
	s.erase(s.find_last_not_of(" ") + 1);
	return s;
}

void split(string &s, string& delim, vector< string > *ret){
	int last = 0;
	int index = s.find_first_of(delim, last);
	while (index != string::npos){
		ret->push_back(s.substr(last, index - last));
		last = index + 1;
		index = s.find_first_of(delim, last);
	}
	if (index - last>0){
		ret->push_back(s.substr(last, index - last));
	}
}

string& cut(string &s,char flag){
	if (s.empty()){
		return s;
	}

	s.erase(0, s.find_first_of(flag));
	return s;
}

int trans(vector<string>content, int i){
	return 1;
}

int main(int argc, char const *argv[]){
    if (argc==1){
        showHelp();
        ofstream outputFile("output.hex",ios::binary|ios::out);
		char *a = "101100";
        outputFile.write(a,sizeof(a));
    }
    else if(argc==2){
        string options=argv[1];
        if (options=="-h"||options=="--help"){
            showHelp();
        }
        else if(options=="-v"||options=="--version"){
            cout<<"Copyright (C) Yeoman Zhuang. All rights reserved."<<endl;
            cout<<"MIPS Compiler: from MIPS to HEX"<<endl;
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
        else if (!outputFile){
            cerr<<"Error: Can not create output file "<<argv[1]<<endl;
            return 1;
        }
        else{
			vector < string > content;
			int length = 0;
			for (; getline(sourceFile, content[length]); length++);
			for (int i = 0; i < content.size(); i++){
				trans(content, i);
			}
        }
    }
    return 0;
}
