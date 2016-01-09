class plane : ScriptObject
{
    RigidBody@ body;
    Vector2 lastImput = Vector2(0,0);
   
    
void Init()
    {
        body = node.CreateComponent("RigidBody");
		CollisionShape@ ColShape = node.CreateComponent("CollisionShape");
		ColShape.SetSphere(1);
		body.mass = 10;
		body.linearDamping = 0.4;
		//body.angularFactor = Vector3(0.5f, 0.5f, 0.5f);
		//body.collisionLayer = 2;
        body.angularDamping = 0.9;
        body.linearDamping = 0.7;
        
        SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
    }
    
void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData)
    {
         DrawHud();
    }

void Update(float timeStep)
    {
       
    }
    
void FixedUpdate(float timeStep)
	{
        body.ApplyForce(Vector3(0,98.1,0));
        body.ApplyForce(body.rotation * Vector3(0,0,500));
        
        // axis indexes: 
        // 0-leftHor 1-leftVert 2-rightHor 3-rightVert 4-leftTrigger 5-rightTrigger
        JoystickState@ joystick = input.joysticksByIndex[0];
        
        float deadzone = 0.7;
        Vector2 stickInput = Vector2(joystick.axisPosition[3],joystick.axisPosition[2]);
        
        Vector2 deltaInput = stickInput - lastImput;
        
        if (stickInput.length > deadzone)
        {
            body.ApplyTorque(body.rotation * (Vector3(stickInput.x * (stickInput.length-deadzone) , 0 , 2 * stickInput.y * (stickInput.length-deadzone)) * -20));
        } else
        {
            body.ApplyTorque(body.rotation * Vector3(deltaInput.x * -50, deltaInput.y * 50,0));
        }
        
        lastImput = stickInput;
    }    

void DrawHud()
    {
        Color hudcol = Color(0.1,1.0,0.1,1.0);
        DebugRenderer@ hud = node.scene.debugRenderer;
        hud.AddLine(node.position + (node.rotation * Vector3(-1,0,100)),node.position + (node.rotation *  Vector3(-3,0,100)), hudcol,false);
        hud.AddLine(node.position + (node.rotation * Vector3(1,0,100)),node.position + (node.rotation *  Vector3(3,0,100)), hudcol,false);
        hud.AddLine(node.position + (node.rotation * Vector3(0,-1,100)),node.position + (node.rotation *  Vector3(0,-3,100)),hudcol,false);
        hud.AddLine(node.position + (node.rotation * Vector3(0,1,100)),node.position + (node.rotation *  Vector3(0,3,100)), hudcol,false);
        
        Vector3 speedvec = body.linearVelocity;
        speedvec.Normalize();
        
        hud.AddCircle(node.position + (speedvec * 100),speedvec, 2 ,hudcol,16 , false);
        log.Info(hud.enabled);
    }
    
}