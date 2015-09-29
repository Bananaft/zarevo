#include "mesh_tools.as";

Scene@ scene_;
Node@ cameraNode;
Node@ cloudNode;

float yaw = 0.0f; // Camera yaw angle
float pitch = 0.0f; // Camera pitch angle
Terrain@ terrain;
RenderPath@ renderpath;

bool pe_bloom = true;
bool pe_fog = true;
bool pe_ae = true;
bool wireframe =false;


void Start()
{
	scene_ = Scene();
	CreateConsoleAndDebugHud();

	SubscribeToEvent("KeyDown", "HandleKeyDown");

	scene_.LoadXML(cache.GetFile("Scenes/kstn_01.xml"));

	cameraNode = Node();
    Camera@ camera = cameraNode.CreateComponent("Camera");
    
	Viewport@ mainVP = Viewport(scene_, camera);
	renderer.viewports[0] = mainVP;
	renderpath = mainVP.renderPath.Clone();
	renderpath.Load(cache.GetResource("XMLFile","RenderPaths/DeferredHWDepth.xml"));
	renderpath.Append(cache.GetResource("XMLFile","PostProcess/AutoExposure.xml"));
    renderpath.Append(cache.GetResource("XMLFile","PostProcess/BloomHDR.xml"));
    renderer.hdrRendering = true;

    renderer.specularLighting = false;
    
    renderer.shadowMapSize = 2048;
	
	mainVP.renderPath = renderpath;
	cameraNode.position = Vector3(0,150,0);
	
	camera.farClip = 12000;
    camera.nearClip = 0.6;
    //log.Info(camera.nearClip);
    camera.fov = 50.0f;
	
	SubscribeToEvent("Update", "HandleUpdate");
    
    Node@ terrNode = scene_.GetChild("Terrain", true);
    terrain = terrNode.GetComponent("Terrain");
    
    Node@ skyNode = scene_.CreateChild("Sky");
    Sky@ sky = cast<Sky>(skyNode.CreateScriptObject(scriptFile, "Sky"));
	sky.Init();
    
    Vector3 clSize = Vector3(400,50,400);
    Array<Vector3> pCloud = BoxPointCloud(500,clSize);
    Geometry@ geom = pCloudToQuadSprites(pCloud);
    Model@ cloudModel = Model();
    
   cloudModel.numGeometries = 1;
   cloudModel.SetGeometry(0, 0, geom);
   cloudModel.boundingBox = BoundingBox(clSize * -1.0, clSize);
   
   cloudNode = scene_.CreateChild("cloudModel");
   cloudNode.position = Vector3(0.0, 100.0, 0.0);
    StaticModel@ object = cloudNode.CreateComponent("StaticModel");
   object.model = cloudModel;
   Material@ CloudMat = Material();
   CloudMat = cache.GetResource("Material","Materials/test_bbl.xml");
   object.material = CloudMat;
   object.castShadows = true;

   //makeClouds(200, 50);
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
                    renderpath.SetEnabled("AutoExposure", false);
                    pe_ae = false;
                } else {
                    renderpath.SetEnabled("AutoExposure", true);
                    pe_ae = true;
                }
        }    else if (key == KEY_V)
        {
            Camera@ cam = cameraNode.GetComponent("camera");
            if (wireframe){
                cam.fillMode = FILL_SOLID;
                wireframe = false;
            } else {
                cam.fillMode = FILL_WIREFRAME;
                wireframe = true;
            }
            
        }

}

void MoveCamera(float timeStep)
{
    // Do not move if the UI has a focused element (the console)
    if (ui.focusElement !is null)
        return;
    Camera@ cam = cameraNode.GetComponent("camera");
    // Movement speed as world units per second
    float MOVE_SPEED;
    if (input.keyDown[KEY_SHIFT]) MOVE_SPEED = 1200.0f; else MOVE_SPEED = 100.0f;
    // Mouse sensitivity as degrees per pixel
    const float MOUSE_SENSITIVITY = 0.1 * 1/cam.zoom;

    // Use this frame's mouse motion to adjust camera node yaw and pitch. Clamp the pitch between -90 and 90 degrees
    IntVector2 mouseMove = input.mouseMove;
    yaw += MOUSE_SENSITIVITY * mouseMove.x;
    pitch += MOUSE_SENSITIVITY * mouseMove.y;
    pitch = Clamp(pitch, -90.0f, 90.0f);

    // Construct new orientation for the camera scene node from yaw and pitch. Roll is fixed to zero
    cameraNode.rotation = Quaternion(pitch, yaw, 0.0f);

    // Read WASD keys and move the camera scene node to the corresponding direction if they are pressed
    if (input.keyDown['W'])
        cameraNode.Translate(Vector3(0.0f, 0.0f, 1.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['S'])
        cameraNode.Translate(Vector3(0.0f, 0.0f, -1.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['A'])
        cameraNode.Translate(Vector3(-1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['D'])
        cameraNode.Translate(Vector3(1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
        
    int mousescroll = input.mouseMoveWheel;
    cam.zoom = Clamp(cam.zoom + mousescroll * cam.zoom * 0.2, 0.8 , 20.0 );
}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    // Take the frame time step, which is stored as a float
    float timeStep = eventData["TimeStep"].GetFloat();

    // Move the camera, scale movement with time step
    MoveCamera(timeStep);
    Vector3 campos = cameraNode.position;
    float ter_height = terrain.GetHeight(campos) + 0.9;
    if (campos.y<ter_height) cameraNode.position = Vector3(campos.x, ter_height, campos.z);
    
    cloudNode.Rotate(Quaternion(0, 6 * timeStep,0));
}

class Sky : ScriptObject
{
    float Pi = 3.14159;
    
    float daytime = 0;
    float astroStep = 0.00069444444;
    
    Zone@ zone;
    Light@ sun;
    Node@ sunNode;
    
    Color DaySkyColor = Color(0.3,0.4,0.5);
    Color NightSkyColor = Color(0,0,0);
    
    Color SunColor = Color(1,0.95,0.8);
    Ramp SunColorRamp;
    Ramp SkyColorRamp;
    
    
    
    void Init()
    {
        
        //Scene@ scene = node.parent;
        Node@ zoneNode = scene_.GetChild("Zone", true);
        zone = zoneNode.GetComponent("Zone");
        
        sunNode = scene_.GetChild("Sun", true);
        sun = sunNode.GetComponent("Light");
        
        Array<Color> arSunColC = {Color(1,0.93,0.73),Color(1,0.32,0.07),Color(0.73,0.02,0.007),Color(0.0,0.0,0.0)};
        Array<float> arSunColP = { 0.267            , 0.367            , 0.446                , 0.5              };
        
        Array<Color> arSkyColC = {Color(0.21,0.44,0.55),Color(0.08,0.13,0.42),Color(0.009,0.013,0.073),Color(0.003,0.0045,0.024),Color(0.0,0.0,0.0)};
        Array<float> arSkyColP = { 0.435               , 0.580               , 0.630                  , 0.700            , 0.900            };
        
        SunColorRamp.SetRamp (arSunColC,arSunColP);
        SkyColorRamp.SetRamp (arSkyColC,arSkyColP);
     
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
        Color suncol = SunColorRamp.GetColor(suncolPos);
        sun.color = suncol * 2;
        //log.Info( sun.color.ToString());
        
        Color skycol = SkyColorRamp.GetColor(suncolPos);
        zone.ambientColor = skycol * 0.2;
        renderpath.shaderParameters["SkyColor"] = Variant(skycol);
        renderpath.shaderParameters["SunColor"] = Variant(suncol);
        renderpath.shaderParameters["SunDir"] = Variant(sunvec);
        
        daytime += astroStep * timeStep;
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
    
    void FixedUpdate(float timeStep)
	{

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
        billboardObject.material = cache.GetResource("Material", "Materials/test2.xml");
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