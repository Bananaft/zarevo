Scene@ scene_;
Node@ cameraNode;


void Start()
{
	scene_ = Scene();
	CreateConsoleAndDebugHud();
	
	SubscribeToEvent("KeyDown", "HandleKeyDown");
	
	scene_.LoadXML(cache.GetFile("Scenes/kstn_01.xml"));
	
	cameraNode = Node();
    Camera@ camera = cameraNode.CreateComponent("Camera");
    renderer.viewports[0] = Viewport(scene_, camera);
	cameraNode.position = Vector3(0,50,0);
       
    camera.fov = 80.0f;
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