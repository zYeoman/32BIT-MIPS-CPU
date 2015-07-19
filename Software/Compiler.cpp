/*
Filename : Compiler.cpp
Compiler : Visual Studio 2013
Description : Trans MIPS to HEX
Release : 7/18/2015
*/

#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#define VERSION "1.1.2"

using namespace std;

void showHelp(char const *argv[]){
    cout<<"Usage: "<<argv[0]<<" [Source] [Output]"<<endl;
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
    if(s.substr(last)!="")
	   ret->push_back(s.substr(last));
}

string& cut(string &s,char flag = ':'){
	if (s.empty()){
		return s;
	}

	s.erase(0, s.find_first_of(flag) + 1);
	return s;
}

string& comment(string &s){
	if (s.find_first_of('#')!=s.npos)
		s.erase(s.begin() + s.find_first_of('#'), s.end());
    return s;
}

string int2str(int num){
	char tmp[9];
	sprintf_s(tmp, "%08X", num);
	return string(tmp);
}

char char2int(char p){
    switch (p){
        case '0':return 0;
        case '1':return 1;
        case '2':return 2;
        case '3':return 3;
        case '4':return 4;
        case '5':return 5;
        case '6':return 6;
        case '7':return 7;
        case '8':return 8;
        case '9':return 9;
        case 'A':
        case 'a':return 10;
        case 'B':
        case 'b':return 11;
        case 'C':
        case 'c':return 12;
        case 'D':
        case 'd':return 13;
        case 'E':
        case 'e':return 14;
        case 'F':
        case 'f':return 15;
        default: return -1;
    }
}

int str2int(string &s){
	s = trim(s);
	if (s[0] == '$'){
		int tmp = s[2] - '0';
		if (s == "$zero")return 0;
		if (s == "$at")return 1;
		if (s[1] == 'v')return 2 + tmp;
		if (s[1] == 'a')return 4 + tmp;
		if (s[1] == 't')return tmp >= 8 ? 24 : (8 + tmp);
		if (s[1] == 's')return 16 + tmp;
		if (s[1] == 'k')return 26 + tmp;
		if (s == "$gp")return 28;
		if (s == "$sp")return 29;
		if (s == "$fp")return 30;
		if (s == "$ra")return 31;
		throw s;
	}
	if (s == "add")return 0;	   //R,20
	if (s == "sub")return 1;	   //R,22
    if (s == "and")return 2;       //R,24
	if (s == "lw")return 3;		   //I,23
	if (s == "sw")return 4;		   //I,2b
	if (s == "slt")return 5;	   //R,2a
	if (s == "addi")return 6;	   //I,8
    if (s == "sll")return 7;       //R,00
    if (s == "srl")return 8;       //R,02
    if (s == "beq")return 9;       //I,4
    if (s == "andi")return 10;      //I,c
    if (s == "lui")return 11;       //I,f
    if (s == "ori")return 12;       //I,d
    if (s == "or")return 13;        //R,25
	if (s == "j")return 29;         //J,2
	if (s == "jal")return 30;      //J,3
	if (s == "jr")return 31;       //R,08
    if (s[0] == '0'){
        int res = 0;
        if(s[1] == 'x'||s[1] == 'X'){
            for (int i = 2; i != s.length(); ++i){
                char tmp = char2int(s[i]);
                if(tmp < 0) throw (string)"Wrong Num";
                else{
                    res = res * 16 + tmp;
                }
            }
            return res;
        }
        else{
            for (int i = 1;i != s.length(); ++i){
                if(s[i] == '1') res = res * 2 + 1;
                else if(s[i] == '0') res = res * 2;
                else throw (string)"Wrond Num";
            }
            return res;
        }
    }
    else{
        int res = 0;
        char flag = (s[0] == '-');
        for(int i = flag;i != s.length(); ++i){
            char tmp = char2int(s[i]);
                if(tmp < 0 || tmp > 9) throw (string)"Wrong Num";
                else{
                    res = res * 10 + tmp;
                }
        }
        if(flag)res = -res;
        return res;
    }
	return 32;
}

int find(vector<string>&content,string target,unsigned int start=0){
    int lineNum = 0;
    for (unsigned int i = start; i < content.size(); i++){
        string tmp = content[i];
        trim(tmp);
        comment(tmp);
        if (tmp.find(target) != tmp.npos){
            return lineNum;
        }
        if (cut(tmp) != ""){
            lineNum++;
        }
    }
    lineNum = 0;
    for (unsigned int i = start; i >= 0; i--){
        string tmp = content[i];
        trim(tmp);
        comment(tmp);
        if (tmp.find(target) != tmp.npos){
            return lineNum;
        }
        if (cut(tmp) != ""){
            lineNum--;
        }
    }
    return 0;
}

int trans(ofstream &output, vector<string>&content, int index, int line){
	vector<string> ret;
	if (content[index]==""){
		return 1;
	}
	else{
		string thisLine = content[index];
		cut(thisLine);
		comment(thisLine);
		trim(thisLine);
		if (thisLine == ""){
			return 2;
		}
		int instruct;
		int opt;
		split(thisLine, (string)" ,()", &ret);
		output << int2str(line * 4) << ' ';
		opt = str2int(ret[0]);
		int opn = (unsigned int)opt < 29 ? 4 : 2;
        opn = (opt == 11 ? 3 : opn);
		if (ret.size() != opn){
			cerr << "Error Instruction: Line " << index + 1 << " incorrect num of register" << endl;
            cerr << thisLine << "  " << ret.size() << endl;
			exit(2);
		}
        int tmp = 0;
		unsigned int lineNum = 0;
		try{
			switch (opt){
			//add sub and slt
			case 0:
			case 1:
            case 2:
			case 5:instruct = 0x20 + opt * 2 + (str2int(ret[1]) << 11) + (str2int(ret[2]) << 21) + (str2int(ret[3]) << 16);
				break;
			//lw sw
			case 3:instruct = (0x23 << 26) + (str2int(ret[1]) << 16) + (str2int(ret[3]) << 21) + (str2int(ret[2]));
                break;
			case 4:instruct = (0x2B << 26) + (str2int(ret[1]) << 16) + (str2int(ret[3]) << 21) + (str2int(ret[2]));
				break;
            //addi
            case 6:instruct = (8 << 26) + (str2int(ret[1]) << 16) + (str2int(ret[2]) << 21) + ((str2int(ret[3]))&0x0000FFFF);
                break;
            //sll
			case 7:instruct = (str2int(ret[1]) << 11) + (str2int(ret[2]) << 16) + (str2int(ret[3]) << 6);
                break;
            //srl
			case 8:instruct = 0x02 + (str2int(ret[1]) << 11) + (str2int(ret[2]) << 16) + (str2int(ret[3]) << 6);
                break;
            //beq
            case 9:instruct = (4 << 26) + (str2int(ret[1]) << 21) + (str2int(ret[2]) << 16);
                tmp = find(content,ret[3] + ":",index);
                tmp -= tmp > 0;
                instruct += (tmp)&0x0000FFFF;
                break;
            //andi
            case 10:instruct = (0x0C << 26) + (str2int(ret[1]) << 16) + (str2int(ret[2]) << 21) + ((str2int(ret[3]))&0x0000FFFF);
                break;
            //lui
            case 11:instruct = (0x0F << 26) + (str2int(ret[1]) << 16) + ((str2int(ret[2]))&0x0000FFFF);
                break;
            //ori
            case 12:instruct = (0x0D << 26) + (str2int(ret[1]) << 16) + (str2int(ret[2]) << 21) + ((str2int(ret[3]))&0x0000FFFF);
                break;
            //or
            case 13:instruct = 0x25 + (str2int(ret[1]) << 11) + (str2int(ret[2]) << 21) + (str2int(ret[3]) << 16);
                break;
			case 29:instruct = (2 << 26);
                instruct += find(content,ret[1]+":");
                break;
            case 30:instruct = (3 << 26);
                instruct += find(content,ret[1]+":");
                break;
            case 31:instruct = (str2int(ret[1]) << 21) + 0x08; break;
			default:
				cerr << "Error Instruction: Line " << index + 1 << "No such Instruction \"" << ret[0] << "\"" << endl;
				exit(0);
				break;
			}
		}
		catch (string s){
			cerr << "Error Register: Line" << index + 1 << "No such Register \"" << s << "\"" << endl;
            cerr << thisLine << endl;
			exit(1);
		}
        char opcode[9];
        sprintf_s(opcode,"%08X",instruct);
		output << opcode;
		output << endl;
	}
	return 0;
}

int main(int argc, char const *argv[]){
    if (argc==1){
        showHelp(argv);
    }
    else if(argc==2){
        string options=argv[1];
        if (options=="-h"||options=="--help"){
            showHelp(argv);
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
		ifstream sourceFile(argv[1]);
		// ifstream sourceFile("D:\\Code\\CPU\\gcd.asm");
		// ofstream outputFile("D:\\Code\\CPU\\gcd.hex");
		ofstream outputFile(argv[2]);
        if (!sourceFile){
            cerr<<"Error: Can not open source file "<<argv[1]<<endl;
            return 1;
        }
        else if (!outputFile){
            cerr<<"Error: Can not create output file "<<argv[2]<<endl;
            return 1;
        }
        else{
			vector < string > content;
			int line = 0;
			for (string tmp; getline(sourceFile, tmp);){
				content.push_back(tmp);
			}
			for (unsigned int i = 0; i < content.size(); i++){
				if (!trans(outputFile, content, i, line))line++;
			}
        }
    }
    return 0;
}