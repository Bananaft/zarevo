#include "mesh_tools.as";

class world : ScriptObject
{
	
	
void	Init()
	{

		Node@ skyNode = node.CreateChild("Sky");
		Node@ Sun = skyNode.CreateChild("Sun");
		Node@ SunMdl = Sun.CreateChild("SunMdl");
		SunMdl.rotation  = Quaternion(0,180,0);
		
		skyNode.rotation = Quaternion(62,0,0);
		
		Light@ SunLight =  Sun.CreateComponent("Light");
		SunLight.lightType = LIGHT_DIRECTIONAL;
		SunLight.castShadows = true;
		SunLight.shadowFocus = FocusParameters(false,true,false,0.5,3);
		SunLight.shadowCascade = CascadeParameters(50,360,1600,5000,1,0.95);
		SunLight.shadowBias = BiasParameters(0.000003, 4);
		
		
		StaticModel@ SunModel = SunMdl.CreateComponent("StaticModel");
		SunModel.model = cache.GetResource("Model", "Models/sun.mdl");
		SunMdl.Scale(200);
		SunModel.material = cache.GetResource("Material", "Materials/sun.xml");
		
		Sky@ sky = cast<Sky>(skyNode.CreateScriptObject(scriptFile, "Sky"));
		sky.Init();
		
		
		Vector3 clSize = Vector3(120,30,120);
		Array<Vector3> pCloud = BoxPointCloud(500,clSize);
		Geometry@ geom = pCloudToQuadSprites(pCloud);
		Model@ cloudModel = Model();
		
	   cloudModel.numGeometries = 1;
	   cloudModel.SetGeometry(0, 0, geom);
	   cloudModel.boundingBox = BoundingBox(clSize * -1.0, clSize);
	   
	   Material@ CloudMat = Material();
	   CloudMat = cache.GetResource("Material","Materials/test_bbl.xml");
	   
	   for (int i=0; i<100; i++)
	   {
		   Node@ cloudNode = scene_.CreateChild("cloudModel");
		   cloudNode.position = Vector3(Random(5500), 100.0 + Random(200), Random(-6000));
		   StaticModel@ object = cloudNode.CreateComponent("StaticModel");
		   object.model = cloudModel;
		   
		   object.material = CloudMat;
		   object.castShadows = true;
	   }
	}
}

class Sky : ScriptObject
{
    float Pi = 3.14159;
    
    float daytime = 0;
    float astroStep = 0.00069444444;
	bool timepass = false;
    
   
    Light@ sun;
    Node@ sunNode;
    
    
    Ramp SunColorRamp;
    Ramp SkyColorRamp;
    
    
    
    void Init()
    {
        
        sunNode = node.GetChild("Sun", false);
        sun = sunNode.GetComponent("Light");
        
        Array<Color> arSunColC = {Color(1,0.93,0.73),Color(1,0.32,0.07),Color(0.73,0.06,0.002),Color(0.0,0.0,0.0)};
        Array<float> arSunColP = { 0.267            , 0.367            , 0.446                , 0.5              };
        
        Array<Color> arSkyColC = {Color(0.32,0.64,0.95),Color(0.08,0.13,0.42),Color(0.009,0.013,0.073),Color(0.003,0.0045,0.024),Color(0.0,0.0,0.0)};
        Array<float> arSkyColP = { 0.435               , 0.580               , 0.630                  , 0.700            , 0.900            };
        
        SunColorRamp.SetRamp (arSunColC,arSunColP);
        SkyColorRamp.SetRamp (arSkyColC,arSkyColP);
     
    }
    
    void Update(float timeStep)
	{
       
        float skyColorLerp = 1 + 3 * Sin(360 * daytime);
        if(skyColorLerp>1)skyColorLerp=1;
        else if (skyColorLerp<0)skyColorLerp=0;
        
       
        sunNode.rotation = Quaternion( 0.0f, 360 * daytime - 90, 0.0f );
        
        Vector3 sunvec = sunNode.worldDirection;// * Vector3(0,1,0);

        float suncolPos = 0.5 + 0.5 * sunvec.y;
        Color suncol = SunColorRamp.GetColor(suncolPos) * 8;
        suncol.r = Pow(suncol.r,2.2);
        suncol.g = Pow(suncol.g,2.2);
        suncol.b = Pow(suncol.b,2.2);
        sun.color = suncol;

        Color skycol = Color(0.3984,0.5117,0.7305);// SkyColorRamp.GetColor(suncolPos) * 6;
        skycol.r = Pow(skycol.r,2.2);
        skycol.g = Pow(skycol.g,2.2);
        skycol.b = Pow(skycol.b,2.2);
      
        renderpath.shaderParameters["SkyColor"] = Variant(skycol);
        renderpath.shaderParameters["SunColor"] = Variant(Color(0.7031,0.4687,0.1055));
        renderpath.shaderParameters["SunDir"] = Variant(sunvec);
        
        if (timepass)daytime += astroStep * timeStep;
        if (daytime > 1) daytime -= 1;
        if (daytime < 0) daytime += 1;
       
        //int mousescroll = input.mouseMoveWheel;
        //daytime += mousescroll * 0.01;
        //log.Info((6+Ceil(daytime*24)) + ":" + Ceil((Ceil((1-daytime)*24)-(1-daytime)*24)*60));
             if (input.keyDown[KEY_KP_PLUS]) daytime += 0.001;
        else if (input.keyDown[KEY_KP_MINUS]) daytime -= 0.001;
        
//        if (input.keyDown[KEY_LEFT]) sunNode.parent.Rotate(Quaternion(0,0,-1));
//        else if (input.keyDown[KEY_RIGHT]) sunNode.parent.Rotate(Quaternion(0,0,1));
        
    }
    

}

class Ramp
{
    Array<Color> Colors;
    Array<float> Positions;
    
    void SetRamp ( Array<Color> Cols, Array<float> Poss)
    {
        Colors = Cols;
        Positions = Poss;
    }
    
    Color GetColor (float pos)
    {
       Color col = Color(0,0,0);
       for (uint i=0; i<Colors.length;i++)
       {
           if (Positions[i]>pos)
           {
               Color Col1 = Colors[i];
               if (i==0)
               {
                    col = Col1;
                    break;
               }
               else
               {
                    Color Col2 = Colors[i-1];
                    float lerp = 1-((pos - Positions[i-1]) / (Positions[i] - Positions[i-1]));
                    col = Col1.Lerp(Col2,lerp);
                    break;
               }
           } 
           else if (i == Colors.length-1)
           {
                col = Colors[i];
           }
       }
       
       return col;
    }

}
