Scene@ scene_;
Node@ cameraNode;
float yaw = 0.0f; // Camera yaw angle
float pitch = 0.0f; // Camera pitch angle
Terrain@ terrain;

 
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
	RenderPath@ renderpath = mainVP.renderPath.Clone();
	renderpath.Load(cache.GetResource("XMLFile","RenderPaths/DeferredHWDepth.xml"));
	renderpath.Append(cache.GetResource("XMLFile","PostProcess/BloomHDR.xml"));
	renderpath.Append(cache.GetResource("XMLFile","PostProcess/AutoExposure.xml"));
    
    renderer.specularLighting = false;

	
	mainVP.renderPath = renderpath;
	cameraNode.position = Vector3(0,150,0);
	
	camera.farClip = 12000;
    camera.fov = 80.0f;
	
	SubscribeToEvent("Update", "HandleUpdate");
    
    Node@ terrNode = scene_.GetChild("Terrain", true);
    terrain = terrNode.GetComponent("Terrain");
    
    Node@ skyNode = scene_.CreateChild("Sky");
    Sky@ sky = cast<Sky>(skyNode.CreateScriptObject(scriptFile, "Sky"));
	sky.Init();
    
    
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

}

void MoveCamera(float timeStep)
{
    // Do not move if the UI has a focused element (the console)
    if (ui.focusElement !is null)
        return;

    // Movement speed as world units per second
    const float MOVE_SPEED = 100.0f;
    // Mouse sensitivity as degrees per pixel
    const float MOUSE_SENSITIVITY = 0.1f;

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
}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    // Take the frame time step, which is stored as a float
    float timeStep = eventData["TimeStep"].GetFloat();

    // Move the camera, scale movement with time step
    MoveCamera(timeStep);
    Vector3 campos = cameraNode.position;
    float ter_height = terrain.GetHeight(campos) + 0.17;
    if (campos.y<ter_height) cameraNode.position = Vector3(campos.x, ter_height, campos.z);
}

class Sky : ScriptObject
{
    
    float daytime = 0;
    float astroStep = 0.01;
    
    Zone@ zone;
    Light@ sun;
    Node@ sunNode;
    
    Color DaySkyColor = Color(0.5,0.5,0.5);
    Color NightSkyColor = Color(0,0,0);
    
    Color SunColor = Color(1,1,1);
    
    
    void Init()
    {
        //Scene@ scene = node.parent;
        Node@ zoneNode = scene_.GetChild("Zone", true);
        zone = zoneNode.GetComponent("Zone");
        
        sunNode = scene_.GetChild("Sun", true);
        zone = zoneNode.GetComponent("Light");
    }
    
    void Update(float timeStep)
	{
       
        //node.Rotate(Quaternion(0.5 * mousescroll, Vector3(0,1,0)));
        
        //skyColorLerp = Clamp(0,1,0.5 + sin());
        
        //zone.ambientColor = Color(mousescroll,0,0);
        
        daytime += astroStep * timeStep;
        if (daytime > 1) daytime -= 1;
        int mousescroll = input.mouseMoveWheel;
        daytime += mousescroll * 0.01;
    }
    
    void FixedUpdate(float timeStep)
	{
         
    }
}