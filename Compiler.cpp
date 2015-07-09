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

#define VERSION 0.9

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
		while (index == last){
			last++;
			index = s.find_first_of(delim, last);
		}
	}
	if (index - last>0){
		ret->push_back(s.substr(last, index - last));
	}
}

string& cut(string &s,char flag = ':'){
	if (s.empty()){
		return s;
	}

	s.erase(0, s.find_first_of(flag));
	return trim(s);
}

string int2str(int num){
	char tmp[8];
	sprintf_s(tmp, "%08X", num*4);
	return string(tmp);
}

char str2int(string &s){
	s = trim(s);
	if (s[0] == '$'){
		int tmp = s[2] - '0';
		if (s == "$zero")return 0;
		if (s == "$at")return 1;
		if (s[1] == 'v')return 2 + tmp;
		if (s[1] == 'a')return 4 + tmp;
		if (s[1] == 't')return tmp >= 8 ? 24 : 8 + tmp;
		if (s[1] == 's')return 16 + tmp;
		if (s[1] == 'k')return 26 + tmp;
		if (s == "$gp")return 28;
		if (s == "$sp")return 29;
		if (s == "$fp")return 30;
		if (s == "$ra")return 31;
		throw s;
	}
	if (s == "add")return 0;	//R,20
	if (s == "sub")return 1;	//R,22
	if (s == "beq")return 2;	//I,4
	if (s == "lw")return 3;		//I,23
	if (s == "sw")return 4;		//I,2b
	if (s == "slt")return 5;	//R,2a
	if (s == "addi")return 6;	//I,8
	if (s == "j")return 7;		//j,2
	if (s == "jal")return 8;	//j,3
	if (s == "jr")return 9;		//R,08
	return 15;
}

int trans(ofstream &output, vector<string>&content, int index, int line){
	vector<string> ret;
	if (content[index]==""){
		return 1;
	}
	else{
		string thisLine = trim(cut(content[index], ':'));
		if (thisLine==""){
			return 2;
		}
		int instruct;
		int opt;
		split(thisLine, (string)" ,()", &ret);
		output << int2str(line * 4) << ' ';
		opt = str2int(ret[0]);
		if (ret.size() != (unsigned int)opt <= 6 ? 4 : 2){
			cerr << "Error Instruction: Line " << index << " incorrect num of register" << endl;
			exit(2);
		}
		unsigned int lineNum = 0;
		try{
			switch (opt){
				//add sub slt
			case 0:
			case 1:
			case 5:instruct = 0x20 + opt * 2 + (str2int(ret[1]) << 11) + (str2int(ret[2]) << 21) + (str2int(ret[3]) << 16);
				break;
			//addi beq
			case 2:
			case 6:instruct = ((opt + 2) << 26) + (str2int(ret[1]) << 16) + (str2int(ret[2]) << 21) + (atoi(ret[3].c_str()))^0x0000FFFF;
				break;
			//lw sw
			case 3:
			case 4:instruct = ((0x23 + opt == 4 ? 8 : 0) << 26) + (str2int(ret[1]) << 16) + (str2int(ret[3]) << 21) + (atoi(ret[2].c_str()));
				break;
			case 7:
			case 8:instruct = ((opt-5) << 26);
				for (unsigned int i = 0; i < content.size(); i++){
					string tmp = trim(content[i]);
					if (content[i].find(ret[2]) != content[i].npos)instruct += ((lineNum+(cut(tmp)=="")) << 2);
					if (cut(tmp) != ""){
						lineNum++;
					}
				}
				break;
			case 9:instruct = (str2int(ret[1]) << 21) + 0x08; break;
			default:
				cerr << "Error Instruction: Line " << index << "No such Instruction \"" << ret[0] << "\"" << endl;
				exit(0);
				break;
			}
		}
		catch (string s){
			cerr << "Error Register: Line" << index << "No such Register \"" << s << "\"" << endl;
			exit(1);
		}
		output << endl;
	}
	return 0;
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
            cout<<"MIPS Compiler: from MIPS to HEX"<<endl;
            cout<<"Version: "<<VERSION<<endl;
        }
    }
    else if(argc>3){
        cerr<<"Error: Too many argument"<<endl;
    }
    else{
        ifstream sourceFile(argv[0]);
        ofstream outputFile(argv[1]);
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
			int line = 0;
			for (string tmp; getline(sourceFile, tmp);){
				if (tmp != ""){
					content.push_back(tmp);
				}
			}
			for (unsigned int i = 0; i < content.size(); i++){
				if (trans(outputFile, content, i, line))line++;
			}
        }
    }
    return 0;
}
