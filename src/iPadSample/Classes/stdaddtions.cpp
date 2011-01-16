/*
 *  stdaddtions.cpp
 *  RopeBurnXCode
 *
 *  Created by Timothy Kerchmar on 1/5/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include "stdaddtions.h"
#include <sstream>

using namespace std;

vector<string> split(string input, string splitOn) {
	vector<string> output;
	size_t findStartIndex = 0, foundIndex;
	
	do {
		foundIndex = input.find(splitOn, findStartIndex);
		string partStr = input.substr(findStartIndex, foundIndex != string::npos ? foundIndex - findStartIndex : string::npos);
		findStartIndex = foundIndex + splitOn.length();
		
		output.push_back(partStr);
	} while(foundIndex != string::npos);
	
	return output;
}

string::size_type replace(string& s,
						  const string& from,
						  const string& to)
{
	string::size_type cnt(string::npos);
	
	if(from != to && !from.empty())
	{
		string::size_type pos1(0);
		string::size_type pos2(0);
		const string::size_type from_len(from.size());
		const string::size_type to_len(to.size());
		cnt = 0;
		
		while((pos1 = s.find(from, pos2)) != string::npos)
		{
			s.replace(pos1, from_len, to);
			pos2 = pos1 + to_len;
			++cnt;
		}
	}
	
	return cnt;
}

string toString(double val) {
	ostringstream returnVal;
	returnVal << val;
	return returnVal.str();
}

float stringToFloat(string str) {
	istringstream strStream(str);
	float someFloat;
	strStream >> someFloat;
	
	if(strStream.bad() || strStream.fail()) return FloatNAN;
	
	return someFloat;
}

int stringToInt(string str) {
	istringstream strStream(str);
	int someInt;
	strStream >> someInt;
	
	if(strStream.bad() || strStream.fail()) return 0;
	
	return someInt;
}

bool isValid(b2Vec2 vec) {
	return !isnan(vec.x) && !isnan(vec.y);
}
