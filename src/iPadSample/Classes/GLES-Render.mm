/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

#include "GLES-Render.h"
#include "TSVertex.h"
#include "TSSequence.h"
#include "TSPositionColorTex0Shader.h"

#include <cstdio>
#include <cstdarg>

#include <cstring>

void GLESDebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	TSVertex glVertices[16];
	
	uint theColor = (uint(color.r * 255.0f) << 24) + (uint(color.g * 255.0f) << 16) + (uint(color.b * 255.0f) << 8) + 0xFF;
	
	for (int32 i = 0; i < vertexCount; ++i)
	{
		b2Vec2 v = vertices[i];
		glVertices[i].position[1] = v.x * drawScale.x + offset.x;
		glVertices[i].position[0] = v.y * drawScale.y + offset.y;
		glVertices[i].color = theColor;
	}
	
	// Use VBO for vertex/index data
	glBindBuffer(GL_ARRAY_BUFFER, TSSequence::buffersVBO[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(glVertices), glVertices, GL_STREAM_DRAW);
	TSPositionColorTex0Shader::getInstance()->setActive();
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void GLESDebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	TSVertex glVertices[16];
	
	uint theColor = (uint(color.r * 255.0f) << 24) + (uint(color.g * 255.0f) << 16) + (uint(color.b * 255.0f) << 8) + 0xFF;
	
	for (int32 i = 0; i < vertexCount; ++i)
	{
		b2Vec2 v = vertices[i];
		glVertices[i].position[1] = v.x * drawScale.x + offset.x;
		glVertices[i].position[0] = v.y * drawScale.y + offset.y;
		glVertices[i].color = theColor;
	}
	
	// Use VBO for vertex/index data
	glBindBuffer(GL_ARRAY_BUFFER, TSSequence::buffersVBO[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(TSVertex) * vertexCount, glVertices, GL_STREAM_DRAW);
	TSPositionColorTex0Shader::getInstance()->setActive();
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
	
	for (int32 i = 0; i < vertexCount; ++i)
	{
		glVertices[i].color &= 0xFFFFFF7F;
	}
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

void GLESDebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	b2Vec2 vertices[16];

	const float32 k_increment = 2.0f * b2_pi / 16.0f;
	float32 theta = 0.0f;
	
	for (int32 i = 0; i < 16; ++i)
	{
		vertices[i] = center + radius * b2Vec2(cosf(theta), sinf(theta));
		theta += k_increment;
	}
	
	DrawPolygon(vertices, 16, color);
}

void GLESDebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	b2Vec2 vertices[16];
	
	const float32 k_increment = 2.0f * b2_pi / 16.0f;
	float32 theta = 0.0f;
	
	for (int32 i = 0; i < 16; ++i)
	{
		vertices[i] = center + radius * b2Vec2(cosf(theta), sinf(theta));
		theta += k_increment;
	}
	
	DrawSolidPolygon(vertices, 16, color);
}

void GLESDebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	b2Vec2 vertices[2] = {p1, p2};
	DrawPolygon(vertices, 2, color);
}

void GLESDebugDraw::DrawTransform(const b2Transform& xf)
{
	b2Vec2 p1 = xf.position, p2;
	const float32 k_axisScale = 1.0f;

	p2 = p1 + k_axisScale * xf.R.col1;
	DrawSegment(p1,p2,b2Color(1,0,0));
	
	p2 = p1 + k_axisScale * xf.R.col2;
	DrawSegment(p1,p2,b2Color(0,1,0));
}

void GLESDebugDraw::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)
{
	glColor4f(color.r, color.g, color.b,1);
	glPointSize(size);
	GLfloat				glVertices[] = {
		p.x * drawScale.x, p.y * drawScale.y
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_POINTS, 0, 1);
	glPointSize(1.0f);
}

void GLESDebugDraw::DrawString(int x, int y, const char *string, ...)
{

	/* Unsupported as yet. Could replace with bitmap font renderer at a later date */
}

void GLESDebugDraw::DrawAABB(b2AABB* aabb, const b2Color& c)
{
	
	glColor4f(c.r, c.g, c.b,1);

	GLfloat				glVertices[] = {
		aabb->lowerBound.x, aabb->lowerBound.y,
		aabb->upperBound.x, aabb->lowerBound.y,
		aabb->upperBound.x, aabb->upperBound.y,
		aabb->lowerBound.x, aabb->upperBound.y
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_LINE_LOOP, 0, 8);
	
}
