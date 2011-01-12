//
//  Shader.fsh
//  iPadSample
//
//  Created by Timothy Kerchmar on 11/30/10.
//  Copyright 2010 The Night School, LLC. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
