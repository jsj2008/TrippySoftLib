//
//  Shader.vsh
//  iPadSample
//
//  Created by Timothy Kerchmar on 11/30/10.
//  Copyright 2010 The Night School, LLC. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord1;

varying vec4 colorVarying;
varying vec2 texCoord1Varying;

void main()
{
    gl_Position = position;

    colorVarying = color;
	texCoord1Varying = texCoord1;
}
