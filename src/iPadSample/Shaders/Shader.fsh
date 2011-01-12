//
//  Shader.fsh
//  iPadSample
//
//  Created by Timothy Kerchmar on 11/30/10.
//  Copyright 2010 The Night School, LLC. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 texCoord1Varying;
uniform sampler2D texture1;

void main()
{
    gl_FragColor = texture2D(texture1, texCoord1Varying) * colorVarying;
}
