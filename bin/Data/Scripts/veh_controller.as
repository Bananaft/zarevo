class veh_controller : ScriptObject
{
	float deadzone = 0.35;
    float livezone = 0.95;
    float inpCurve = 1.5;
	float plainsens = 2.0;
	float deltasens = 8.0;
	
	
	Vector2 lastImput = Vector2(0,0);
	Vector2 speed = Vector2(0,0);
	Node@ vehnode;
	Node@ campivot;
	Node@ campivot2;
void Init()
    {
        vehnode = node.scene.CreateChild("vehnode");
		campivot = vehnode.CreateChild("campivot");
		campivot2 = campivot.CreateChild("campivot");
		node.parent = campivot2;
		
		vehnode.position = Vector3(-200,200,0);
		node.position = Vector3(0,4,-10);
        SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
		
		StaticModel@ boxybox = vehnode.CreateComponent("StaticModel");
		boxybox.model = cache.GetResource("Model", "Models/Box.mdl");
		boxybox.castShadows = true;
		
    }
	
Vector2 MapInput(Vector2 inp)
{

    
    //float maplength = 1 + (1-livezone);
    //Vector2 Ninp = inp; 
    //Ninp.Normalize();
    
    //mapInp = (inp - Ninp * deadzone) / (livezone-deadzone);
    
    //mapInp = Vector2(Pow(mapInp.x,inpCurve),Pow(mapInp.y,inpCurve));
    
    float r = inp.length;
    float Phi = Atan2(inp.x, inp.y);
    
        
    if (r < deadzone) return Vector2(0,0);
    
    r = Pow((r - deadzone) / (livezone-deadzone), inpCurve );
    
    Vector2 mapInp = Vector2(r * Sin(Phi), r * Cos(Phi));
    
    if (mapInp.length>1) mapInp.Normalize();
    
    return mapInp; 
}
	
void Update(float timeStep)
	{

	}
void FixedUpdate(float timeStep)
	{
		JoystickState@ joystick = input.joysticksByIndex[0];
	
		Vector2 stickInput = Vector2(joystick.axisPosition[3],joystick.axisPosition[2]);
		float pedals = joystick.axisPosition[4] - joystick.axisPosition[5];
		Vector2 mappedInput = MapInput(stickInput); 
		
		Vector2 deltaInput = stickInput - lastImput;
		lastImput = stickInput;
		Vector2 finalinput = mappedInput * plainsens + deltaInput * deltasens;
		
		campivot.Rotate(Quaternion(0,finalinput.y,0.));
		campivot2.Rotate(Quaternion(finalinput.x,0,0.));
		Vector3 spdvc =  campivot.rotation * Vector3(joystick.axisPosition[0], 0, -1 * joystick.axisPosition[1]);
		if (spdvc.length > 0.5) speed += Vector2(spdvc.x, spdvc.z) * 0.03;
		speed *= 0.98;		
		vehnode.position += Vector3(speed.x,0,speed.y);
        Terrain@ terr = scene.GetChild("terrain").GetComponent("terrain");
        vehnode.position = Vector3(vehnode.position.x,terr.GetHeight(vehnode.position) + 0.4,vehnode.position.z);
	}
void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData)
    {
         DrawHud();
    }	
void DrawHud()
    {
        Vector3 pos = node.worldPosition;
		Quaternion rot = node.worldRotation;
		Color hudcol = Color(0.1,1.0,0.1,1.0);
        Color hudcol2 = Color(1.0,0.6,0.1,1.0);
        DebugRenderer@ hud = node.scene.debugRenderer;
        hud.AddLine(pos + (rot * Vector3(-1,0,100)),pos + (rot *  Vector3(-3,0,100)), hudcol,false);
        hud.AddLine(pos + (rot * Vector3(1,0,100)),pos + (rot *  Vector3(3,0,100)), hudcol,false);
        hud.AddLine(pos + (rot * Vector3(0,-1,100)),pos + (rot *  Vector3(0,-3,100)),hudcol,false);
        hud.AddLine(pos + (rot * Vector3(0,1,100)),pos + (rot *  Vector3(0,3,100)), hudcol,false);
		
		hud.AddCircle(pos + (rot * Vector3(70,-35,100)),rot * Vector3(0,0,1), 10 ,hudcol,32 , false);
        hud.AddCircle(pos + (rot * Vector3(70,-35,100)),rot * Vector3(0,0,1), 10 * deadzone ,hudcol,32 , false);
        //hud.AddCross(pos + (rot * Vector3(70 + lastImput.x * 10,-35 + lastImput.y * 10,100)),5,hudcol, false);
        hud.AddCircle(pos + (rot * Vector3(70 + lastImput.y * 10,-35 + lastImput.x * 10,100)),rot * Vector3(0,0,1), 1 ,hudcol,8 , false);
        Vector2 lastImputMapped = MapInput(lastImput);
        hud.AddCircle(pos + (rot * Vector3(70 + lastImputMapped.y * 10,-35 + lastImputMapped.x * 10,100)),rot * Vector3(0,0,1), 1 ,hudcol2,8 , false);
	}
}


