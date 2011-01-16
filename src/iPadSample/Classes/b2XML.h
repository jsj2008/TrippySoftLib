/*
 *  b2XML.h
 *  RopeBurnXCode
 *
 *  Ported to C++ by Timothy Kerchmar on 1/14/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */
/*
 * Copyright (c) 2009 Adam Newgas http://www.boristhebrave.com
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
/**
 * Contains functions for loading Box2D shapes, bodies and joints from a simple XML format.
 * 
 * <p>The XML format is formally defined in using <a href="http://relaxng.org/">Relax NG</a> in the file
 * <a href="box2d.rng">box2d.rng</a> found in the same directory as this class.
 * An <a href="http://www.w3.org/XML/Schema">XML Schema</a> file is also <a href="box2d.xsd">available</a>, autotranslated by 
 * <a href="http://www.thaiopensource.com/relaxng/trang.html">Trang</a>.</p>
 * 
 * <p>Simply stated, the XML format has a root &lt;world/&gt; element. Inside that, there are various body and joint elements, 
 * and inside each body element is various shape elements, thus matching Box2Ds design layout quite closely.
 * See the methods loadShapeDef, loadBodyDef, and loadJointDef for the details on how each element is formed.</p>
 * 
 * <p>In general, attribute names match exactly the corresponding Box2D property, and has the same defaults as Box2D.
 * Reasonable values are generated for certain properties when not specified, in the same manner as the various
 * Initialize functions of Box2D. Joint anchors can be specified in either world or local co-ordinates, either single
 * or jointly, though this implementation will not prevent you from overspecifying attributes.</p>
 * 
 * <p>It is expected that in most cases, you will not want to use the XML to fully define worlds using loadWorld, as
 * this library doesn't provide any mechanism for handling other data, such as the appearance of a body. Instead, you
 * can use the various loading functions to synthesize your own XML format containing parts of the Box2D XML specification.
 * Or you can simply use this class as a more consise and portable way of writing out defintions, and deal with defining
 * the world in your own way.</p>
 * 
 * @see #loadShapeDef()
 * @see #loadBodyDef()
 * @see #loadJointDef()
 */

#include <Box2D/Box2D.h>
#include "tinyxml.h"
#include <tr1/unordered_map>

class b2XML {
public:
	/**
	 * Loads a Number from a given attribute.
	 * @param	attribute	An attribute list of zero or one attributes to parse into a Number.
	 * @param	defacto		The default number to use in case there is no attribute or it is not a valid Number.
	 * @return The parsed Number, or defacto.
	 */
	static float loadFloat(const char* attribute, float defacto);
	
	/**
	 * Loads a angle from a given attribute. Angles are read like loadFloat, with an optional letter suffix.
	 * "d" indicates the angle is in degrees, not radians.
	 * @param	attribute	An attribute list of zero or one attributes to parse into a Number.
	 * @param	defacto		The default number to use in case there is no attribute or it is not a valid Number.
	 * @return The parsed Number, or defacto.
	 */
	static float loadAngle(const char* attribute, float defacto);
	
	/**
	 * Loads a int from a given attribute.
	 * @param	attribute	An attribute list of zero or one attributes to parse into a int.
	 * @param	defacto		The default number to use in case there is no attribute or it is not a valid int.
	 * @return The parsed int, or defacto.
	 */
	static int loadInt(const char* attribute, int defacto);
	
	/**
	 * Loads a Boolean from a given attribute. Only the value "true" is recognized as true. Everything else is false.
	 * @param	attribute	An attribute list of zero or one attributes to parse into a Boolean.
	 * @param	defacto		The default number to use in case there is no attribute.
	 * @return The parsed Boolean, or defacto.
	 */
	static bool loadBool(const char* attribute, bool defacto);
	
	/**
	 * Loads a String from a given attribute.
	 * @param	attribute	An attribute list of zero or one attributes.
	 * @param	defacto		The default number to use in case there is no attribute.
	 * @return The attribute, if it exists, or defacto.
	 */
	static std::string loadString(const char* attribute, std::string defacto);
	
	/**
	 * Loads a b2Vec2 from a given attribute. Vectors are stored as space delimited Numbers, e.g. "1.5 2.3".
	 * @param	attribute	An attribute list of zero or one attributes to parse into a b2Vec2.
	 * @param	defacto		The default number to use in case there is no attribute or it is not a valid b2Vec2.
	 * @return The parsed b2Vec2, or defacto.
	 */
	static b2Vec2 loadVec2(const char* attribute, b2Vec2 defacto);
	
	/**
	 * Reads a b2FixtureDef from xml. The element type and it's children are ignored, only
	 * attributes are read.
	 * 
	 * <p>The following attributes are supported:</p>
	 * <pre>
	 * density        float
	 * friction       float
	 * isSensor       Boolean
	 * userData       String
	 * categoryBits   int
	 * maskBits       int
	 * groupIndex     int</pre>
	 * @param	base A fixture definition to use as the default when an XML attribute is missing.
	 */
	static b2FixtureDef loadFixtureDef(TiXmlElement* xml, b2FixtureDef* base = NULL);
	
	/**
	 * Converts an XML element into a b2Shape.
	 * 
	 * <p>The following elements/usages are recognized:</p>
	 * <pre>
	 * &lt;circle radius="0." x="0." y="0."/&gt;
	 * 	    b2CircleDef 
	 * &lt;circle radius="0." localPosition="0. 0."/&gt;
	 * 	    b2CircleDef    
	 * &lt;polygon&gt;
	 * 	&lt;vertex x="0." y="0."/&gt;
	 *  &lt;vertex x="0." y="0."/&gt;
	 *  &lt;vertex x="0." y="0."/&gt;
	 * &lt;/polygon&gt;
	 * 	    b2PolygonDef
	 * &lt;box x="0." y="0." width="0." height="0." angle="0."/&gt;
	 * 	    b2PolygonDef formed into an OBB.
	 * &lt;box left="" right="" top="" bottom=""/&gt;
	 * 	    b2PolygonDef formed into an AABB.
	 * 	    height and width can substitute for one of top/bottom and one of left/right.</pre>
	 * 
	 * 
	 * @param	shape An XML element in the above format
	 * @return	The corresponding b2Shape
	 */
	static b2Shape* loadShape(TiXmlElement* shape);
	
	/**
	 * Converts a &lt;body/&gt; element into a b2BodyDef.
	 * 
	 * <p>The following attributes are recognized, corresponding directly
	 * to the b2BodyDef properties:</p>
	 * <pre>
	 * allowSleep       Boolean
	 * angle            Number
	 * angularDamping   Number
	 * fixedRotation    Boolean
	 * bullet           Boolean
	 * awake            Boolean
	 * linearDamping    Number
	 * x                Number
	 * y                Number
	 * position         b2Vec2
	 * userData         &#x2A; 	</pre>
	 * @param	body An XML element in the above format.
	 * @param	base A body definition to use as the default when an XML attribute is missing.
	 * @return The specified b2BodyDef.
	 */
	static b2BodyDef loadBodyDef(TiXmlElement* body, b2BodyDef* base = NULL);
	
	/**
	 * Creates a body from a &lt;body/&gt; element with nested shape elements, using the definitions from loadBodyDef and loadShapeDef.
	 * @param	xml	The &lt;body/&gt; element to parse.
	 * @param	world	The world to create the body from.
	 * @param	bodyDef	The base body definition to use for defaults.
	 * @param	fixtureDef A fixture definition to use for defaults.
	 * @return A newly created body in world.
	 * @see #loadBodyDef()
	 * @see #loadShapeDef()
	 */
	static b2Body* loadBody(TiXmlElement* xml, b2World* world, b2BodyDef* bodyDef = NULL, b2FixtureDef* fixtureDef = NULL);
	
	/**
	 * Reads common joint def attributes from xml.
	 */
	static void assignJointDefFromXML(TiXmlElement* xml, b2JointDef* to, b2Body* bodyA, b2Body* bodyB, b2JointDef* base = NULL);
	
	/**
	 * Converts an XML element into a b2JointDef.
	 * 
	 * <p>The following elements and attributes are recognized:</p>
	 * <pre>
	 * &lt;gear/&gt;    b2GearJointDef
	 *         ratio           Number
	 *         joint1          String    (resolved)
	 *         joint2          String    (resolved)
	 * 
	 * &lt;prismatic/&gt; b2PrismaticJointDef
	 *         motorSpeed      Number
	 *         maxMotorForce   Number
	 *         enableMotor     Boolean   (automatically set)
	 *         lower           Number
	 *         upper           Number
	 *         enableLimits    Boolean   (automatically set)
	 *         referenceAngle  Number    (automatically set)
	 *         world-axis      b2Vec2
	 *         local-axisA     b2Vec2
	 * 
	 * &lt;revolute/&gt;    b2RevoluteJointDef
	 *         motorSpeed      Number
	 *         maxMotorTorque  Number
	 *         enableMotor     Boolean   (automatically set)
	 *         lower           Number
	 *         upper           Number
	 *         enableLimits    Boolean   (automatically set)
	 *         referenceAngle  Number    (automatically set)
	 * 
	 * &lt;distance/&gt;    b2DistanceJointDef
	 *         dampingRatio    Number
	 *         frequencyHz     Number
	 *         length          Number    (automatically set)
	 * 
	 * &lt;pulley/&gt; b2PulleyJointDef
	 *         ratio           Number
	 *         maxLength-a     Number
	 *         maxLength-b     Number
	 *         world-ground    b2Vec2
	 *         world-groundA   b2Vec2
	 *         world-groundB   b2Vec2
	 *         length-a        Number    (automatically set)
	 *         length-b        Number    (automatically set)
	 * 
	 * &lt;mouse/&gt;    b2MouseJointDef
	 *         dampingRatio    Number
	 *         frequencyHz     Number
	 *         maxForce        Number
	 *         target          b2Vec2 </pre>
	 * 
	 * <p>Additionally, all elements support the following attributes:</p>
	 * <pre>
	 * body1             String          (resolved)
	 * body2             String          (resolved)
	 * world-anchor      b2Vec2
	 * world-anchorA     b2Vec2
	 * world-anchorB     b2Vec2
	 * local-anchorA     b2Vec2
	 * local-anchorB     b2Vec2
	 * collideConnected  Boolean </pre>
	 * 
	 * <p>Note that if the joint does not have a well defined body from bodyA/bodyB or via providing base,
	 * then world co-ordinates cannot be used, except for the ground anchors of a pulley joint.</p>
	 * 
	 * @param	joint An XML element in the above format
	 * @param	resolver A function mapping strings to b2Bodys (and b2Joint).
	 * This is used so that the bodyA and bodyB (and joint1 and joint2 from &lt;gear/&gt;) can get resolved
	 * to the correct references. You can avoid using this if these properties are not defined, and providing them via base.
	 * @param	base A joint definition to use as the default when an XML attribute is missing.
	 * @return	The corresponding b2ShapeDef
	 */
	static b2JointDef loadJointDef(TiXmlElement* joint, std::tr1::unordered_map<std::string, void*> &resolver, b2JointDef* base = NULL);
	
	/**
	 * Loads a world given a XML defintion. 
	 * 
	 * <p>xml is expected to a &lt;world&gt; element with child &lt;body&gt; and joint elements as specified in
	 * loadBodyDef and loadShapeDef. &lt;body/&gt; elements should have children shape elements as 
	 * specified in loadShapeDef.</p>
	 * 
	 * <p>Both body and joint elements can have an id attribute that gives a string identifier
	 * to be later resolved for use with the body1 and body2 attributes of joints,
	 * and joint1 and joint2 attribute of gear joints.</p>
	 * 
	 * @param	xml		A <world/> element in the above format.
	 * @param	world	A world to load into. Unlike other load functions, this function does not create an object from scratch.
	 * @param	bodyDef	A body definition to use for defaults.
	 * @param	fixtureDef A fixture definition to use for defaults.
	 * @param	jointDef A joint definition to use for defaults.
	 * @return A function you can use to resolve the loaded elements, as defined in loadJointDef.
	 * @see #loadJointDef
	 */
	static void loadWorld(TiXmlElement* xml, b2World* world, 
						  std::tr1::unordered_map<std::string, void*> &resolver, 
						  b2BodyDef* bodyDef = NULL, 
						  b2FixtureDef* fixtureDef = NULL, 
						  b2JointDef* jointDef = NULL);
};