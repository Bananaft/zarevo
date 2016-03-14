#include "mesh_tools.as";
#include "freelookCam.as";
#include "plane.as";

Scene@ scene_;
//Node@ cameraNode;
Node@ cloudNode;

bool pe_bloom = true;
bool pe_fog = true;
bool pe_ae = true;
bool wireframe =false;

Terrain@ terrain;
RenderPath@ renderpath;
bool renderInit = false;

bool timepass =true;



void Start()
{
	cache.autoReloadResources = true;
    
    scene_ = Scene();
	CreateConsoleAndDebugHud();

	SubscribeToEvent("KeyDown", "HandleKeyDown");

	scene_.LoadXML(cache.GetFile("Scenes/kstn_01.xml"));
   // scene_.CreateComponent("PhysicsWorld");

	Node@ cameraNode = scene_.CreateChild("CamNode");
    Camera@ camera = cameraNode.CreateComponent("Camera");
	Viewport@ mainVP = Viewport(scene_, camera);
    freelookCam@ flcam = cast<freelookCam>(cameraNode.CreateScriptObject(scriptFile, "freelookCam"));
    flcam.Init();
    
    renderer.viewports[0] = mainVP;
	renderpath = mainVP.renderPath.Clone();
    
    renderer.hdrRendering = true;
    
	
	renderpath.Load(cache.GetResource("XMLFile","RenderPaths/DeferredHWDepth.xml"));
    renderer.viewports[0].renderPath = renderpath;
    
    //scene_.CreateComponent("DebugRenderer");
    
    
//    Node@ planeNode = scene_.CreateChild("plane");
//    cameraNode.parent = planeNode;
//	cameraNode.position = Vector3(0,0.6,2.5);
//    planeNode.position = Vector3(0,150,0);
//    plane@ plane = cast<plane>(planeNode.CreateScriptObject(scriptFile, "plane"));
//    plane.Init();
//	
//	StaticModel@ PplaneModel = planeNode.CreateComponent("StaticModel");
//	PplaneModel.model = cache.GetResource("Model", "Models/Vehicles/aircrafts/f16");
//	PplaneModel.material = cache.GetResource("Material", "Materials/test1.xml");
//	PplaneModel.castShadows = true;

    

    renderer.specularLighting = false;
    
    renderer.shadowMapSize = 2048;
    renderer.shadowQuality = 3;
    
	
	
	
	
	camera.farClip = 12000;
    camera.nearClip = 0.6;
    //log.Info(camera.nearClip);
    camera.fov = 50.0f;
	
	SubscribeToEvent("Update", "HandleUpdate");
    SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
    
    Node@ terrNode = scene_.GetChild("Terrain", true);
    terrain = terrNode.GetComponent("Terrain");
    
    Node@ skyNode = scene_.CreateChild("Sky");
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
       cloudNode = scene_.CreateChild("cloudModel");
       cloudNode.position = Vector3(Random(5500), 100.0 + Random(200), Random(-6000));
       StaticModel@ object = cloudNode.CreateComponent("StaticModel");
       object.model = cloudModel;
       
       object.material = CloudMat;
       object.castShadows = true;
   }
  
	
   for (int i=0; i<20; i++)
   {
		Node@ aiPlaneNode = scene_.CreateChild("aiPlane");
		aiPlaneNode.position = Vector3(0, 300, 50 * i);
		StaticModel@ planeModel = aiPlaneNode.CreateComponent("StaticModel");
		planeModel.model = cache.GetResource("Model", "Models/Vehicles/aircrafts/f16");
		planeModel.material = cache.GetResource("Material", "Materials/test1.xml");
		planeModel.castShadows = true;
		
		plane@ aiplane = cast<plane>(aiPlaneNode.CreateScriptObject(scriptFile, "plane"));
		aiplane.Init();
		aiplane.autopilot = true;
   }
   

}

void initRender()
{
    
    Viewport@ vp = renderer.viewports[0];
	renderpath = vp.renderPath.Clone();
    
   
    
	renderpath.Append(cache.GetResource("XMLFile","PostProcess/AutoExposure.xml"));
    //renderpath.Append(cache.GetResource("XMLFile","PostProcess/bn_HDR.xml"));
    renderpath.Append(cache.GetResource("XMLFile","PostProcess/BloomHDR.xml"));
    //renderpath.shaderParameters["AutoExposureAdaptRate"] = 100000.0f;
    //renderpath.SetEnabled("AutoExposureFix", false);
    renderer.viewports[0].renderPath = renderpath;
    renderInit = true;
}

void CreateConsoleAndDebugHud()
{
    // Get default style
    XMLFile@ xmlFile = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    if (xmlFile is null)
        return;

    // Create console
    Console@ console = engine.CreateConsole();
    console.defaultStyle = xmlFile;
    console.background.opacity = 0.8f;

    // Create debug HUD
    DebugHud@ debugHud = engine.CreateDebugHud();
    debugHud.defaultStyle = xmlFile;

}

void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData)
    {

    }


void HandleKeyDown(StringHash eventType, VariantMap& eventData)
{
    int key = eventData["Key"].GetInt();

    // Close console (if open) or exit when ESC is pressed
    if (key == KEY_ESC)
    {
        if (!console.visible)
            engine.Exit();
        else
            console.visible = false;
    }

    // Toggle console with F1
    else if (key == KEY_F1)
        console.Toggle();

    // Toggle debug HUD with F2
    else if (key == KEY_F2)
        debugHud.ToggleAll();

    // Take screenshot
    else if (key == KEY_F12)
        {
            Image@ screenshot = Image();
            graphics.TakeScreenShot(screenshot);
            // Here we save in the Data folder with date and time appended
            screenshot.SavePNG(fileSystem.programDir + "Data/Screenshot_" +
                time.timeStamp.Replaced(':', '_').Replaced('.', '_').Replaced(' ', '_') + ".png");
        }
     else if (key == KEY_B) 
        {
            if (pe_bloom)
                {
                    renderpath.SetEnabled("BloomHDR", false);
                    pe_bloom = false;
                } else {
                    renderpath.SetEnabled("BloomHDR", true);
                    pe_bloom = true;
                }
        }
     else if (key == KEY_F) 
        {
            if (pe_fog)
                {
                    renderpath.SetEnabled("Sky", false);
                    pe_fog = false;
                } else {
                    renderpath.SetEnabled("Sky", true);
                    pe_fog = true;
                }
        }
        
      else if (key == KEY_E) 
        {
            if (pe_ae)
                {
                    //renderpath.SetEnabled("AutoExposureFix", false);
                    renderpath.SetEnabled("AutoExposure", false);
                    pe_ae = false;
                } else {
                    renderpath.SetEnabled("AutoExposure", true);
                    //renderpath.SetEnabled("AutoExposureFix", true);
                    pe_ae = true;
                }
        }    //else if (key == KEY_V)
 /*       {
            Camera@ cam = cameraNode.GetComponent("camera");
            if (wireframe){
                cam.fillMode = FILL_SOLID;
                wireframe = false;
            } else {
                cam.fillMode = FILL_WIREFRAME;
                wireframe = true;
            }
            
        }*/
    else if (key == KEY_T) 
        {
            if(timepass) timepass = false; else timepass = true;
        }    
        

}

void MoveCamera(float timeStep)
{

}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    // Take the frame time step, which is stored as a float
    float timeStep = eventData["TimeStep"].GetFloat();
    if (timepass) cloudNode.Rotate(Quaternion(0, 3 * timeStep,0));
    
    // HDR hack: http://urho3d.prophpbb.com/post10052.html?hilit=HDR#p10052
    if (scene_.elapsedTime > 0.5f && !renderInit) 
    {
        //renderpath.shaderParameters["AutoExposureAdaptRate"] = 0.6f;
        //renderpath.SetEnabled("AutoExposureFix", true);
        initRender();
    }
    
}

class Sky : ScriptObject
{
    float Pi = 3.14159;
    
    float daytime = 0;
    float astroStep = 0.00069444444;
    
    Zone@ zone;
    Light@ sun;
    Node@ sunNode;
    
    
    Ramp SunColorRamp;
    Ramp SkyColorRamp;
    Ramp ZenColorRamp;
    
    
    
    void Init()
    {
        
        //Scene@ scene = node.parent;
        Node@ zoneNode = scene_.GetChild("Zone", true);
        zone = zoneNode.GetComponent("Zone");
        
        sunNode = scene_.GetChild("Sun", true);
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
        //float sunheight = 
        float suncolPos = 0.5 + 0.5 * sunvec.y;
        Color suncol = SunColorRamp.GetColor(suncolPos) * 8;
        suncol.r = Pow(suncol.r,2.2);
        suncol.g = Pow(suncol.g,2.2);
        suncol.b = Pow(suncol.b,2.2);
        sun.color = suncol;
        //log.Info( sun.color.ToString());
        Color zencol = ZenColorRamp.GetColor(suncolPos) * 6;
        zencol.r = Pow(zencol.r,2.2);
        zencol.g = Pow(zencol.g,2.2);
        zencol.b = Pow(zencol.b,2.2);
        Color skycol = SkyColorRamp.GetColor(suncolPos) * 6;
        skycol.r = Pow(skycol.r,2.2);
        skycol.g = Pow(skycol.g,2.2);
        skycol.b = Pow(skycol.b,2.2);
        //zone.ambientColor = skycol * 0.2;
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

void makeClouds(int NumClouds, int NumBboards)
{
    
    for (uint i = 0; i < NumClouds; ++i)
    {
        Node@ smokeNode = scene_.CreateChild("Smoke");
        smokeNode.position = Vector3(Random(12000.0f) - 6000.0f, Random(120.0f) + 300.0f, Random(12000.0f) - 6000.0f);

        BillboardSet@ billboardObject = smokeNode.CreateComponent("BillboardSet");
        billboardObject.numBillboards = NumBboards;
        billboardObject.material = cache.GetResource("Material", "Materials/test_nm.xml");
        billboardObject.sorted = true;
        billboardObject.castShadows = true;

        for (uint j = 0; j < NumBboards; ++j)
        {
            Billboard@ bb = billboardObject.billboards[j];
            bb.position = Vector3(Random(300.0f) - 150.0f, Random(40.0f) - 20.0f, Random(80.0f) - 40.0f);
            float size= 6+Random(15);
            bb.size = Vector2(size, size);
            bb.rotation = Random() * 360.0f;
            bb.enabled = true;
        }

        // After modifying the billboards, they need to be "commited" so that the BillboardSet updates its internals
        billboardObject.Commit();
    }

}