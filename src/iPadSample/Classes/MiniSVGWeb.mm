/*
 *  MiniSVGWeb.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/3/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include "MiniSVGWeb.h"
#include "stdaddtions.h"

SvgArc::SvgArc(float x, float y, float startAngle, float arc, float radius, float yRadius, float xAxisRotation, float cx, float cy) :
	x(x), y(y), startAngle(startAngle), arc(arc), radius(radius), yRadius(yRadius), xAxisRotation(xAxisRotation), cx(cx), cy(cy)
{
}


vector<vector<string> > MiniSVGWeb::graphicsCommands;
float MiniSVGWeb::currentX;
float MiniSVGWeb::currentY;
float MiniSVGWeb::startX;
float MiniSVGWeb::startY;
float MiniSVGWeb::lastCurveControlX;
float MiniSVGWeb::lastCurveControlY;

void MiniSVGWeb::parse(TiXmlElement* path, TSSVGDelegate* delegate) {
	generateGraphicsCommands(path);
	draw(delegate, path);
}

TSMatrix* MiniSVGWeb::parseTransform(char* tran, TSMatrix* baseMatrix) {
	if (!baseMatrix) baseMatrix = new TSMatrix();
	
	// The AS3 MiniSVGWeb used a regex /\S+\(.*?\)/sg to match
	// and then processed those transforms. When debugging 
	// the flash version to find out the results of this regex,
	// the result was always tran. There could be SVGs where the transform
	// requires the regex, but I don't understand it and I don't need it.
	if (tran != NULL && tran[0] != 0) {
		char* commandStr = strtok(tran, "(");
		char* argsStr = strtok(NULL, "");
		
		if(commandStr && argsStr) {
			string command = commandStr;
			string args = argsStr;
			
			replace(args, ")", "");
			replace(args, " ", ","); //Replace spaces with a comma
			replace(args, ",,", ","); // Remove any extra commas
			// check flash version, not removing leading trailing commas
			
			vector<string> argsArray = split(args, ",");
					
			TSMatrix nodeMatrix;
			
			if(command == "matrix" && argsArray.size() == 6) {
				nodeMatrix.a = atof(argsArray[0].c_str());
				nodeMatrix.b = atof(argsArray[1].c_str());
				nodeMatrix.c = atof(argsArray[2].c_str());
				nodeMatrix.d = atof(argsArray[3].c_str());
				nodeMatrix.tx = atof(argsArray[4].c_str());
				nodeMatrix.ty = atof(argsArray[5].c_str());
			}
			else if(command == "translate" && argsArray.size() == 2) {
				nodeMatrix.tx = atof(argsArray[0].c_str());
				nodeMatrix.ty = atof(argsArray[1].c_str());
			}
			else if(command == "scale") {
				if(argsArray.size() == 1) {
					nodeMatrix.a = atof(argsArray[0].c_str());
					nodeMatrix.d = atof(argsArray[0].c_str());
				}
				else if(argsArray.size() == 2) {
					nodeMatrix.a = atof(argsArray[0].c_str());
					nodeMatrix.d = atof(argsArray[1].c_str());
				}
			}
			else if(command == "skewX") {
				nodeMatrix.c = tan(atof(argsArray[0].c_str()) * M_PI / 180.0);
			}
			else if(command == "skewY") {
				nodeMatrix.b = tan(atof(argsArray[0].c_str()) * M_PI / 180.0);
			}
			else if(command == "rotate") {
				if(argsArray.size() == 3) {
					nodeMatrix.translate(-atof(argsArray[1].c_str()), -atof(argsArray[2].c_str()));
					nodeMatrix.rotate(atof(argsArray[0].c_str()) * M_PI / 180.0);
					nodeMatrix.translate( atof(argsArray[1].c_str()),  atof(argsArray[2].c_str()));
				}
				else if(argsArray.size() == 1) {
					nodeMatrix.rotate(atof(argsArray[0].c_str()) * M_PI / 180.0);
				}
			}
			else {
				NSLog(@"Unknown Transformation: %s", command.c_str());
			}
			
			baseMatrix->concat(&nodeMatrix);
		}
	}

	return baseMatrix;
}

void MiniSVGWeb::draw(TSSVGDelegate* delegate, TiXmlElement* path) {
	float firstX = 0.0f;
	float firstY = 0.0f;
	
	for(int i = 0; i < graphicsCommands.size(); i++) {
		vector<string> &command = graphicsCommands[i];
		
		if(command[0] == "SF") {
			delegate->beginPath(path);
		}
		else if(command[0] == "EF") {
			delegate->endPath();
		}
		else if(command[0] == "M") {
			firstX = atof(command[1].c_str());
			firstY = atof(command[2].c_str());
			
			delegate->moveTo(firstX, firstY);
		}
		else if(command[0] == "L") {
			delegate->lineTo(atof(command[1].c_str()), atof(command[2].c_str()));
		}
		else if(command[0] == "C") {
			delegate->curveTo(atof(command[1].c_str()), atof(command[2].c_str()), atof(command[3].c_str()), atof(command[4].c_str()));
		}
		else if(command[0] == "Z") {
			delegate->lineTo(firstX, firstY);
		}
		else if(command[0] == "LINE") {
			delegate->moveTo(atof(command[1].c_str()), atof(command[2].c_str()));
			delegate->lineTo(atof(command[3].c_str()), atof(command[4].c_str()));
		}
		else if(command[0] == "RECT") {
			if(command.size() == 5) {
				delegate->drawRect(atof(command[1].c_str()), atof(command[2].c_str()), atof(command[3].c_str()), atof(command[4].c_str()));
			}
			else {
				delegate->drawRoundRect(atof(command[1].c_str()), atof(command[2].c_str()), atof(command[3].c_str()), atof(command[4].c_str()), atof(command[5].c_str()), atof(command[6].c_str()));
			}
		}
		else if(command[0] == "CIRCLE") {
			delegate->drawCircle(atof(command[1].c_str()), atof(command[2].c_str()), atof(command[3].c_str()));
		}
		else if(command[0] == "ELLIPSE") {
			delegate->drawEllipse(atof(command[1].c_str()), atof(command[2].c_str()), atof(command[3].c_str()), atof(command[4].c_str()));
		}
	}
}

/**
 * Normalize SVG Path Data into an array we can work with.
 */
vector<string> MiniSVGWeb::normalizeSVGData(TiXmlElement* path) {
	// NOTE: This code is very performance sensitive and was 
	// a bottleneck affecting page load; rewritten to not use
	// regular expressions as well as other tricks that were shown
	// to be faster (like caching data.length, parsing right into
	// an array instead of an intermediate string, etc.).
	// Be careful when changing this code without seeing what the
	// performance is before and after. See 
	// Issue 229 for details:
	// "Speedup page load time of MichaelN's static map page on IE"
	// http://code.google.com/p/svgweb/issues/detail?id=229
	
	string data = path->Attribute("d");
	// AS3 version trims whitespace from either end of data,
	// but isnt necessary for current svgs
            
	// In the algorithm below, we are doing a few things. It is
	// unfortunately complicated but it was found to be the primary
	// bottleneck when dealing with lots of PATH statements. 
	// We use the charCode since as a number it is much faster than
	// dealing with strings. We test the value against the Unicode
	// values for the numerical and alphabetical ranges for our 
	// commands, which is fast. We also order our IF statements from
	// most common (numbers) to least common (letter commands). Testing
	// also paradoxically found that simply building up another 
	// string is much faster than having an intermediate array; arrays
	// in ActionScript are very slow, and the final split() method 
	// is very fast at producing an array we can work with
	string results = "";
	int dataLength = data.size();
	string c;
	char code;
	int i = 0;
	
	while (i < dataLength) {
		code = data[i];
				
		// from most common to least common encountered

		if ((code >= 48 && code <= 57) || code == 45 || code == 101 || code == 46) {
			// 0 through 9, -, e-, or .
			do {
				results.push_back(data[i]);
				i++;
				code = data[i];
			} while (((code >= 48 && code <= 57) || code == 46 || code == 101) && code);
			results += ",";
		} else if (code == 44 || code == 32 || code == 10 || code == 13 || code == 0) {
			// just ignore delimiters since we are adding in our own
			// in the correct places
			i++;
		} else if (code >= 65 && code <= 122) {
			// A-Z and a-z
			results.push_back(data[i]);
			results += ",";
			i++;
		} else {
			// unknown character
			i++;
		}
	}
	
	// remove trailing comma, but outside of big loop above
	if (results[results.size() - 1] == ',') {
		results = results.substr(0, results.size() - 1);
	}
	
	//NSLog(@"MiniSVGWeb::normalizeSVGData found %s", results.c_str());
	
	return split(results, ",");
}

void MiniSVGWeb::generateGraphicsCommands(TiXmlElement* path) {
	graphicsCommands.clear();
	
	string command;
	bool lineAbs;
	bool isAbs;
	vector<string> szSegs = normalizeSVGData(path);
	
	vector<string> tempPath;
	tempPath.push_back("SF");
	graphicsCommands.push_back(tempPath);
	
	bool firstMove = true;
	int szSegsLength = szSegs.size();
	for(int pos = 0; pos < szSegsLength; ) {
		command = szSegs[pos++];
		
		//NSLog(@"MiniSVGWeb::generateGraphicsCommands processing command %s", command.c_str());
		
		isAbs = false;
		
		if(command == "M" || command == "A" || command == "C" || command == "Q" || command == "T" || command == "L" || command == "H" || command == "V" || command == "Z") {
			isAbs = true;
		}
		
		if(command == "m" || command == "M") {
			lineAbs = isAbs;
			if (firstMove) { //If first move is 'm' treat as absolute
				isAbs = true;
				firstMove = false;
			}
			
			moveTo(stringToFloat(szSegs[pos+0]), stringToFloat(szSegs[pos+1]), isAbs);
			pos += 2;
			while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos]))) {
				line(stringToFloat(szSegs[pos+0]), stringToFloat(szSegs[pos+1]), lineAbs);
				pos += 2;
			}
		}
		else if(command == "a" || command == "A") {
			do {
				ellipticalArc(stringToFloat(szSegs[pos+0]),
							  stringToFloat(szSegs[pos+1]),
							  stringToFloat(szSegs[pos+2]),
							  stringToFloat(szSegs[pos+3]),
							  stringToFloat(szSegs[pos+4]),
							  stringToFloat(szSegs[pos+5]),
							  stringToFloat(szSegs[pos+6]),isAbs);
				pos += 7;
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}
		else if(command == "c" || command == "C") {
			do {
				cubicBezier(stringToFloat(szSegs[pos+0]),
							stringToFloat(szSegs[pos+1]),
							stringToFloat(szSegs[pos+2]),
							stringToFloat(szSegs[pos+3]),
							stringToFloat(szSegs[pos+4]),
							stringToFloat(szSegs[pos+5]),isAbs);
				
				pos += 6;
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}			
		else if(command == "s" || command == "S") {
			do {
				cubicBezierSmooth(stringToFloat(szSegs[pos+0]),
								  stringToFloat(szSegs[pos+1]),
								  stringToFloat(szSegs[pos+2]),
								  stringToFloat(szSegs[pos+3]),isAbs);
				
				pos += 4;
				
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}
		else if(command == "q" || command == "Q") {
			do {
				quadraticBezier(stringToFloat(szSegs[pos+0]),
								stringToFloat(szSegs[pos+1]),
								stringToFloat(szSegs[pos+2]),
								stringToFloat(szSegs[pos+3]),isAbs);
				
				pos += 4;
				
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}
		else if(command == "t" || command == "T") {
			do {
				quadraticBezierSmooth(stringToFloat(szSegs[pos+0]),
									  stringToFloat(szSegs[pos+1]),isAbs);
				
				pos += 2;
				
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}
		else if(command == "l" || command == "L") {
			do {
				line(stringToFloat(szSegs[pos+0]),
					 stringToFloat(szSegs[pos+1]),isAbs);
				
				pos += 2;
				
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}
		else if(command == "h" || command == "H") {
			do {
				lineHorizontal(stringToFloat(szSegs[pos+0]), isAbs);
				
				pos += 1;
				
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}
		else if(command == "v" || command == "V") {
			do {
				lineVertical(stringToFloat(szSegs[pos+0]), isAbs);
				
				pos += 1;
				
			} while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos])));
		}
		else if(command == "z" || command == "Z") {
			closePath();
			while (pos < szSegsLength && !isnan(stringToFloat(szSegs[pos]))) {
				line(stringToFloat(szSegs[pos+0]),
					 stringToFloat(szSegs[pos+1]),isAbs);
				
				pos += 2;
			}
		}
		else {
//			TS.log("Unknown Segment Type: " + command + " in path " + path->Attribute("id"));
		}
	}        
	
	tempPath.clear();
	tempPath.push_back("EF");
	graphicsCommands.push_back(tempPath);
}

void MiniSVGWeb::closePath() {
	vector<string> tempPath;
	tempPath.push_back("Z");
	graphicsCommands.push_back(tempPath);
	
	currentX = startX;
	currentY = startY;
}

void MiniSVGWeb::moveTo(float x, float y, bool isAbs) {
	if (!isAbs) {
		x += currentX;
		y += currentY;
	}
	
	vector<string> tempPath;
	tempPath.push_back("M");
	tempPath.push_back(toString(x).c_str());
	tempPath.push_back(toString(y).c_str());
	graphicsCommands.push_back(tempPath);
	
	currentX = x;
	currentY = y;
	
	startX = x;
	startY = y;
	
	lastCurveControlX = currentX;
	lastCurveControlY = currentY;
}

void MiniSVGWeb::lineHorizontal(float x, bool isAbs) {
	float y = currentY;
	if (!isAbs) {
		x += currentX;
		isAbs = true;
	}
	line(x,y,isAbs);            
}

void MiniSVGWeb::lineVertical(float y, bool isAbs) {
	float x = currentX;
	if (!isAbs) {
		y += currentY;
		isAbs = true;
	}
	line(x,y,isAbs);            
}

void MiniSVGWeb::line(float x, float y, bool isAbs) {
	if (isAbs) {
		currentX = x;
		currentY = y;
	}
	else {
		currentX += x;
		currentY += y;                
	}            
	
	vector<string> tempPath;
	tempPath.push_back("L");
	tempPath.push_back(toString(currentX).c_str());
	tempPath.push_back(toString(currentY).c_str());
	graphicsCommands.push_back(tempPath);
	
	lastCurveControlX = currentX;
	lastCurveControlY = currentY;        
}

float MiniSVGWeb::ellipticalArc(float rx, float ry, float xAxisRotation, float largeArcFlag, float sweepFlag, float x, float y, bool isAbs) {
	if (!isAbs) {
		x += currentX;
		y += currentY;
	}
	
	SvgArc arc = computeSvgArc(rx, ry, xAxisRotation, 
							bool(largeArcFlag), bool(sweepFlag),
							x, y, currentX, currentY);
	
	if(round(arc.arc) == 360.0 && round(arc.radius - arc.yRadius) == 0.0) {
		
		vector<string> tempPath;
		tempPath.push_back("CIRCLE");
		tempPath.push_back(toString(arc.cx).c_str());
		tempPath.push_back(toString(arc.cy).c_str());
		tempPath.push_back(toString(arc.radius).c_str());
		graphicsCommands.push_back(tempPath);
	}
	
	currentX = x;
	currentY = y;
	
	lastCurveControlX = currentX;
	lastCurveControlY = currentY;
	
	return arc.arc;
}

void MiniSVGWeb::quadraticBezierSmooth(float x, float y, bool isAbs) {
	float x1 = currentX + (currentX - lastCurveControlX);
	float y1 = currentY + (currentY - lastCurveControlY);
	
	if(!isAbs) {
		x += currentX;
		y += currentY;
		
		isAbs = true;
	}
	
	quadraticBezier(x1, y1, x, y, isAbs);
}

void MiniSVGWeb::quadraticBezier(float x1, float y1, float x, float y, bool isAbs) {
	if (!isAbs) {
		x1 += currentX;
		y1 += currentY;
		x += currentX;
		y += currentY;
	}
	
	vector<string> tempArray;
	tempArray.push_back("C");
	tempArray.push_back(toString(x1).c_str());
	tempArray.push_back(toString(y1).c_str());
	tempArray.push_back(toString(x).c_str());
	tempArray.push_back(toString(y).c_str());
	graphicsCommands.push_back(tempArray);
	
	currentX = x;
	currentY = y;
	
	lastCurveControlX = x1;
	lastCurveControlY = y1;
}

void MiniSVGWeb::cubicBezierSmooth(float x2, float y2, float x, float y, bool isAbs) {
	float x1 = currentX + (currentX - lastCurveControlX);
	float y1 = currentY + (currentY - lastCurveControlY);
	
	if (!isAbs)
	{
		x2 += currentX;
		y2 += currentY;                
		x+= currentX;
		y+= currentY;
		
		isAbs = true;
	}
	
	cubicBezier(x1, y1, x2, y2, x, y, isAbs);
}

void MiniSVGWeb::cubicBezier(float x1, float y1, float x2, float y2,
								   float x, float y, bool isAbs) {
	
	if (!isAbs) {
		x1 += currentX;
		y1 += currentY;
		x2 += currentX;
		y2 += currentY;
		x += currentX;
		y += currentY;
	}
	
	b2Vec2 P0(currentX, currentY);
	b2Vec2 P1(x1, y1);
	b2Vec2 P2(x2, y2);
	b2Vec2 P3(x, y);
	
	/* A portion of code from Bezier_lib.as by Timothee Groleau */
	// calculates the useful base points
	b2Vec2 PA = getPointOnSegment(P0, P1, 3/4);
	b2Vec2 PB = getPointOnSegment(P3, P2, 3/4);
	
	// get 1/16 of the [P3, P0] segment
	float dx = (P3.x - P0.x) / 16;
	float dy = (P3.y - P0.y) / 16;
	
	// calculates control point 1
	b2Vec2 Pc_1 = getPointOnSegment(P0, P1, 3/8);
	
	// calculates control point 2
	b2Vec2 Pc_2 = getPointOnSegment(PA, PB, 3/8);
	Pc_2.x -= dx;
	Pc_2.y -= dy;
	
	// calculates control point 3
	b2Vec2 Pc_3 = getPointOnSegment(PB, PA, 3/8);
	Pc_3.x += dx;
	Pc_3.y += dy;
	
	// calculates control point 4
	b2Vec2 Pc_4 = getPointOnSegment(P3, P2, 3/8);
	
	// calculates the 3 anchor points
	b2Vec2 Pa_1 = getMiddle(Pc_1, Pc_2);
	b2Vec2 Pa_2 = getMiddle(PA, PB);
	b2Vec2 Pa_3 = getMiddle(Pc_3, Pc_4);
	
	// draw the four quadratic subsegments
	vector<string> tempArray;
	tempArray.push_back("C");
	tempArray.push_back(toString(Pc_1.x).c_str());
	tempArray.push_back(toString(Pc_1.y).c_str());
	tempArray.push_back(toString(Pa_1.x).c_str());
	tempArray.push_back(toString(Pa_1.y).c_str());
	graphicsCommands.push_back(tempArray);
	
	tempArray.clear();
	tempArray.push_back("C");
	tempArray.push_back(toString(Pc_2.x).c_str());
	tempArray.push_back(toString(Pc_2.y).c_str());
	tempArray.push_back(toString(Pa_2.x).c_str());
	tempArray.push_back(toString(Pa_2.y).c_str());
	graphicsCommands.push_back(tempArray);
	
	tempArray.clear();
	tempArray.push_back("C");
	tempArray.push_back(toString(Pc_3.x).c_str());
	tempArray.push_back(toString(Pc_3.y).c_str());
	tempArray.push_back(toString(Pa_3.x).c_str());
	tempArray.push_back(toString(Pa_3.y).c_str());
	graphicsCommands.push_back(tempArray);
	
	tempArray.clear();
	tempArray.push_back("C");
	tempArray.push_back(toString(Pc_4.x).c_str());
	tempArray.push_back(toString(Pc_4.y).c_str());
	tempArray.push_back(toString(P3.x).c_str());
	tempArray.push_back(toString(P3.y).c_str());
	graphicsCommands.push_back(tempArray);
	
//	graphicsCommands.push(['C', Pc_1.x, Pc_1.y, Pa_1.x, Pa_1.y]);
//	graphicsCommands.push(['C', Pc_2.x, Pc_2.y, Pa_2.x, Pa_2.y]);
//	graphicsCommands.push(['C', Pc_3.x, Pc_3.y, Pa_3.x, Pa_3.y]);
//	graphicsCommands.push(['C', Pc_4.x, Pc_4.y, P3.x, P3.y]);        
	
	currentX = x;
	currentY = y;
	
	lastCurveControlX = x2;
	lastCurveControlY = y2;            
}    

b2Vec2 MiniSVGWeb::getPointOnSegment(b2Vec2 P0, b2Vec2 P1, float ratio)
{
	/* A portion of code from Bezier_lib.as by Timothee Groleau */
	return b2Vec2(P0.x + ((P1.x - P0.x) * ratio), (P0.y + ((P1.y - P0.y) * ratio)));
}                            

b2Vec2 MiniSVGWeb::getMiddle(b2Vec2 P0, b2Vec2 P1) {
	/* A portion of code from Bezier_lib.as by Timothee Groleau */
	return b2Vec2((P0.x + P1.x) * 0.5f, (P0.y + P1.y) * 0.5f);
}

SvgArc MiniSVGWeb::computeSvgArc(float rx, float ry, float angle, 
								 bool largeArcFlag, bool sweepFlag,
									  float x, float y, float LastPointX, float LastPointY) {
	
	//store before we do anything with it     
	float xAxisRotation = angle;     
	
	// Compute the half distance between the current and the final point
	float dx2 = (LastPointX - x) / 2.0f;
	float dy2 = (LastPointY - y) / 2.0f;
	
	// Convert angle from degrees to radians
	angle = degreesToRadians(angle);
	float cosAngle = cos(angle);
	float sinAngle = sin(angle);
	
	//Compute (x1, y1)
	float x1 = cosAngle * dx2 + sinAngle * dy2;
	float y1 = -sinAngle * dx2 + cosAngle * dy2;
	
	// Ensure radii are large enough
	rx = abs(rx);
	ry = abs(ry);
	float Prx = rx * rx;
	float Pry = ry * ry;
	float Px1 = x1 * x1;
	float Py1 = y1 * y1;
	
	// check that radii are large enough
	float radiiCheck = Px1 / Prx + Py1 / Pry;
	if (radiiCheck > 1) {
		rx = sqrt(radiiCheck) * rx;
		ry = sqrt(radiiCheck) * ry;
		Prx = rx * rx;
		Pry = ry * ry;
	}
	
	//Compute (cx1, cy1)
	float sign = (largeArcFlag == sweepFlag) ? -1.0f : 1.0f;
	float sq = ((Prx * Pry) - (Prx * Py1) - (Pry * Px1)) / ((Prx * Py1) + (Pry * Px1));
	sq = (sq < 0) ? 0 : sq;
	float coef = (sign * sqrt(sq));
	float cx1 = coef * ((rx * y1) / ry);
	float cy1 = coef * -((ry * x1) / rx);
	
	
	//Compute (cx, cy) from (cx1, cy1)
	float sx2 = (LastPointX + x) / 2.0;
	float sy2 = (LastPointY + y) / 2.0;
	float cx = sx2 + (cosAngle * cx1 - sinAngle * cy1);
	float cy = sy2 + (sinAngle * cx1 + cosAngle * cy1);
	
	
	//Compute the angleStart (angle1) and the angleExtent (dangle)
	float ux = (x1 - cx1) / rx;
	float uy = (y1 - cy1) / ry;
	float vx = (-x1 - cx1) / rx;
	float vy = (-y1 - cy1) / ry;
	float p; 
	float n;
	
	//Compute the angle start
	n = sqrt((ux * ux) + (uy * uy));
	p = ux;
	
	sign = (uy < 0) ? -1.0 : 1.0;
	
	float angleStart = radiansToDegrees(sign * acos(p / n));
	
	// Compute the angle extent
	n = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
	p = ux * vx + uy * vy;
	sign = (ux * vy - uy * vx < 0) ? -1.0 : 1.0;
	float angleExtent = radiansToDegrees(sign * acos(p / n));
	
	if(!sweepFlag && angleExtent > 0) 
	{
		angleExtent -= 360;
	} 
	else if (sweepFlag && angleExtent < 0) 
	{
		angleExtent += 360;
	}
	
	angleExtent = fmod(angleExtent, 360.0f);
	angleStart = fmod(angleStart, 360.0f);
	
	return SvgArc(LastPointX, LastPointY, angleStart, angleExtent, rx, ry, xAxisRotation, cx, cy);
//	return Object({x:LastPointX,y:LastPointY,startAngle:angleStart,arc:angleExtent,radius:rx,yRadius:ry,xAxisRotation:xAxisRotation, cx:cx,cy:cy});
}

float MiniSVGWeb::degreesToRadians(float angle) {
	return angle * (M_PI / 180.0f);
}

float MiniSVGWeb::radiansToDegrees(float angle) {
	return angle * (180.0f / M_PI);
}
