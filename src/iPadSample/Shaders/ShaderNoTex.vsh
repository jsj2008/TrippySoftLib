//
//  Shader.vsh
//  iPadSample
//
//  Created by Timothy Kerchmar on 11/30/10.
//  Copyright 2010 The Night School, LLC. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

void main()
{
    gl_Position = position;

    colorVarying = color;
}
