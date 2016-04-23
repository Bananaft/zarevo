class world : ScriptObject
{
	
	
void	Init()
	{
		Node@ skyNode = node.CreateChild("Sky");
		skyNode.rotation = Quaternion(62,0,0);
		Node@ Sun = skyNode.CreateChild("Sun");
		Light@ SunLight =  Sun.CreateComponent("Light");
		SunLight.lightType = LIGHT_DIRECTIONAL;
		SunLight.castShadows = true;
		SunLight.shadowFocus = FocusParameters(false,true,false,0.5,3);
		SunLight.shadowCascade = CascadeParameters(50,360,1600,5000,1,0.95);
		SunLight.shadowBias = BiasParameters(0.000003, 4);
		
		Sky@ sky = cast<Sky>(skyNode.CreateScriptObject(scriptFile, "Sky"));
		sky.Init();
	}
}

class Sky : ScriptObject
{
    float Pi = 3.14159;
    
    float daytime = 0;
    float astroStep = 0.00069444444;
	bool timepass = true;
    
   
    Light@ sun;
    Node@ sunNode;
    
    
    Ramp SunColorRamp;
    Ramp SkyColorRamp;
    Ramp ZenColorRamp;
    
    
    
    void Init()
    {
        
        sunNode = node.GetChild("Sun", false);
        sun = sunNode.GetComponent("Light");
        
        Array<Color> arSunColC = {Color(1,0.93,0.73),Color(1,0.32,0.07),Color(0.73,0.06,0.002),Color(0.0,0.0,0.0)};
        Array<float> arSunColP = { 0.267            , 0.367            , 0.446                , 0.5              };
        
        Array<Color> arSkyColC = {Color(0.32,0.64,0.95),Color(0.08,0.13,0.42),Color(0.009,0.013,0.073),Color(0.003,0.0045,0.024),Color(0.0,0.0,0.0)};
        Array<float> arSkyColP = { 0.435               , 0.580               , 0.630                  , 0.700            , 0.900            };
        
        Array<Color> arZenColC = {Color(0.04,0.27,1.00),Color(0.002,0.003,0.111),Color(0.0001,0.0015,0.005),Color(0.0,0.0,0.0)};
        Array<float> arZenColP = {         0.45               , 0.620                  , 0.700            , 0.900            };
        
        SunColorRamp.SetRamp (arSunColC,arSunColP);
        SkyColorRamp.SetRamp (arSkyColC,arSkyColP);
        ZenColorRamp.SetRamp (arZenColC,arZenColP);
     
    }
    
    void Update(float timeStep)
	{
       
        float skyColorLerp = 1 + 3 * Sin(360 * daytime);
        if(skyColorLerp>1)skyColorLerp=1;
        else if (skyColorLerp<0)skyColorLerp=0;
        
       
        sunNode.rotation = Quaternion( 0.0f, 360 * daytime - 90 , 0.0f );
        
        Vector3 sunvec = sunNode.worldDirection;// * Vector3(0,1,0);

        float suncolPos = 0.5 + 0.5 * sunvec.y;
        Color suncol = SunColorRamp.GetColor(suncolPos) * 8;
        suncol.r = Pow(suncol.r,2.2);
        suncol.g = Pow(suncol.g,2.2);
        suncol.b = Pow(suncol.b,2.2);
        sun.color = suncol;

        Color zencol = ZenColorRamp.GetColor(suncolPos) * 6;
        zencol.r = Pow(zencol.r,2.2);
        zencol.g = Pow(zencol.g,2.2);
        zencol.b = Pow(zencol.b,2.2);
        Color skycol = SkyColorRamp.GetColor(suncolPos) * 6;
        skycol.r = Pow(skycol.r,2.2);
        skycol.g = Pow(skycol.g,2.2);
        skycol.b = Pow(skycol.b,2.2);
      
        renderpath.shaderParameters["ZenColor"] = Variant(zencol);
        renderpath.shaderParameters["SkyColor"] = Variant(skycol);
        renderpath.shaderParameters["SunColor"] = Variant(suncol);
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
