#include "freelookCam.as";
#include "veh_controller.as";
#include "bnterrain.as";
#include "world.as";

RenderPath@ renderpath;
Scene@ scene_;

bool pe_bloom = true;
bool pe_fog = true;
bool pe_ae = true;
bool wireframe =false;

void Start()
{
	cache.autoReloadResources = true;
	
	scene_ = Scene();
	scene_.LoadXML(cache.GetFile("Scenes/kstn_01.xml"));
	
	//scene_.CreateComponent("Octree");
    //scene_.CreateComponent("PhysicsWorld");
	
	CreateConsoleAndDebugHud();

	SubscribeToEvent("KeyDown", "HandleKeyDown");

	initRender();
}

void initRender()
{
   	Node@ cameraNode = scene_.CreateChild("CamNode");
    Camera@ camera = cameraNode.CreateComponent("Camera");
	
	camera.farClip = 12000;
    camera.nearClip = 0.6;
    camera.fov = 50.0f;
	
	Viewport@ mainVP = Viewport(scene_, camera);
    veh_controller@ flcam = cast<veh_controller>(cameraNode.CreateScriptObject(scriptFile, "veh_controller"));
	flcam.Init();
	
	//Node@ terrNode = scene_.CreateChild("terrain");
	//bnterrain@ bn_terrain = cast<bnterrain>(terrNode.CreateScriptObject(scriptFile, "bnterrain"));
	//bn_terrain.Init();
	
	Node@ worldNode = scene_.CreateChild("world");
	world@ world = cast<world>(worldNode.CreateScriptObject(scriptFile, "world"));
	world.Init();
	
    renderer.hdrRendering = true;
	
	renderer.textureFilterMode = FILTER_ANISOTROPIC;
	renderer.textureAnisotropy = 8;
	
	renderer.viewports[0] = mainVP;
	renderpath = mainVP.renderPath.Clone();
    
    
    
	
	renderpath.Load(cache.GetResource("XMLFile","RenderPaths/DeferredHWDepth.xml"));
	renderpath.Append(cache.GetResource("XMLFile","PostProcess/AutoExposure.xml"));
    renderpath.Append(cache.GetResource("XMLFile","PostProcess/BloomHDR.xml"));
    renderer.viewports[0].renderPath = renderpath;
	
	renderer.specularLighting = false;
    
    renderer.shadowMapSize = 2048;
    renderer.shadowQuality = 3;

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
        }    else if (key == KEY_V)
        {
            
			Camera@ cam = renderer.viewports[0].camera;
            if (wireframe){
                cam.fillMode = FILL_SOLID;
                wireframe = false;
            } else {
                cam.fillMode = FILL_WIREFRAME;
                wireframe = true;
            }
            
        }

        

}