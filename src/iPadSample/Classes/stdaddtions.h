/*
 *  stdaddtions.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/5/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _STDADDITIONS_H
#define _STDADDITIONS_H

#include <string>
#include <vector>
#include <tr1/unordered_map>
#include <math.h>
#include <limits>

static const float FloatNAN = std::numeric_limits<float>::quiet_NaN();

std::vector<std::string> split(std::string input, std::string splitOn);
std::string::size_type replace(std::string& s, const std::string& from, const std::string& to);
std::string toString(double val);
float stringToFloat(std::string &str);

//namespace __gnu_cxx
//{
//	template<> struct hash< std::string >
//	{
//		size_t operator()( const std::string& x ) const
//		{
//			return hash< const char* >()( x.c_str() );
//		}
//	};
//}

#endif