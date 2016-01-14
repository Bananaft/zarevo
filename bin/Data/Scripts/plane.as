class plane : ScriptObject
{
    RigidBody@ body;
    Vector2 lastImput = Vector2(0,0);
    float deadzone = 0.2;
    float livezone = 0.95;
    float inpCurve = 1.9;
    Array<Vector2> lgraph(500,Vector2(0,0));
    int graphpos = 0;
    
    Vector3 AimVec = Vector3(0,0,1);
    float aimzone = 0.3;
    float rollzone = 0.99;
    
    float RollForce = 6;
    float RollVel = 20;
    
void Init()
    {
        body = node.CreateComponent("RigidBody");
		CollisionShape@ ColShape = node.CreateComponent("CollisionShape");
		ColShape.SetSphere(1);
		body.mass = 10;
		body.linearDamping = 0.4;
		//body.angularFactor = Vector3(0.5f, 0.5f, 0.5f);
		//body.collisionLayer = 2;
        body.angularDamping = 0.99;
        body.linearDamping = 0.8;
        
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
        
        body.ApplyForce(body.rotation * Vector3(0,0,900));
        
        // axis indexes: 
        // 0-leftHor 1-leftVert 2-rightHor 3-rightVert 4-leftTrigger 5-rightTrigger
        JoystickState@ joystick = input.joysticksByIndex[0];
        
        
        Vector2 stickInput = Vector2(joystick.axisPosition[3],joystick.axisPosition[2]);
        Vector2 mappedInput = MapInput(stickInput); 
        
        Vector2 deltaInput = stickInput - lastImput;
        

        //body.ApplyTorque(body.rotation * (Vector3(mappedInput.x  * -1, -1 * mappedInput.y, 0 ) * -20));

        //body.ApplyTorque(body.rotation * Vector3(deltaInput.x * 170, deltaInput.y * 170,0));
		//body.ApplyTorque(body.rotation * Vector3(0, 1,0));
        
        Vector3 fwd   = body.rotation *  Vector3(0,0,1);
        Vector3 top   = body.rotation *  Vector3(0,1,0);        
        Vector3 right =  top.CrossProduct(AimVec); //body.rotation *  Vector3(1,0,0); //
        
        
 
        float permm = 2;
        float deltal = 4;
            
        Quaternion vert = Quaternion(mappedInput.x * permm + deltaInput.x * deltal, right);
        Quaternion hor = Quaternion(mappedInput.y * permm + deltaInput.y * deltal, top );
        AimVec =  vert * hor * AimVec;
        
		
		float fwdDot = fwd.DotProduct(AimVec);
		
		if (fwdDot < aimzone)
		{
			Quaternion qback = Quaternion(100 * (fwdDot-aimzone),fwd.CrossProduct(AimVec));
			AimVec = qback * AimVec;
		}
        
       
        Vector3 rollvec;
        if (fwdDot < rollzone)
        {
            rollvec = body.rotation.Inverse() * AimVec;
            
        } else {
            
            rollvec = body.rotation.Inverse() * Vector3(0,1,0);
        }
        
        rollvec.z = 0;
        rollvec.Normalize();
        
        float roll =  Atan2(rollvec.x, rollvec.y);
        body.ApplyTorque(body.rotation * Vector3(0,0,-1 * Clamp(roll , -1 * RollForce , RollForce)));
        
        //Quaternion QAim;
        //QAim.FromLookRotation(AimVec,top);
        
        Vector3 locaAimVec = body.rotation.Inverse() * AimVec;
        
        body.ApplyTorque(body.rotation * Vector3(locaAimVec.y * -5,locaAimVec.x * 5,0));
        
        
        lastImput = stickInput;
        
        graphpos++;
        if (graphpos > 500) graphpos = 0;
        lgraph[graphpos] = stickInput;
		
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

void DrawHud()
    {
        Color hudcol = Color(0.1,1.0,0.1,1.0);
        Color hudcol2 = Color(1.0,0.6,0.1,1.0);
        DebugRenderer@ hud = node.scene.debugRenderer;
        hud.AddLine(node.position + (node.rotation * Vector3(-1,0,100)),node.position + (node.rotation *  Vector3(-3,0,100)), hudcol,false);
        hud.AddLine(node.position + (node.rotation * Vector3(1,0,100)),node.position + (node.rotation *  Vector3(3,0,100)), hudcol,false);
        hud.AddLine(node.position + (node.rotation * Vector3(0,-1,100)),node.position + (node.rotation *  Vector3(0,-3,100)),hudcol,false);
        hud.AddLine(node.position + (node.rotation * Vector3(0,1,100)),node.position + (node.rotation *  Vector3(0,3,100)), hudcol,false);
        
        Vector3 speedvec = body.linearVelocity;
        speedvec.Normalize();
        
        hud.AddCircle(node.position + (speedvec * 100),speedvec, 2 ,hudcol,16 , false);
        
        hud.AddCircle(node.position + (node.rotation * Vector3(70,-35,100)),node.rotation * Vector3(0,0,1), 10 ,hudcol,32 , false);
        hud.AddCircle(node.position + (node.rotation * Vector3(70,-35,100)),node.rotation * Vector3(0,0,1), 10 * deadzone ,hudcol,32 , false);
        //hud.AddCross(node.position + (node.rotation * Vector3(70 + lastImput.x * 10,-35 + lastImput.y * 10,100)),5,hudcol, false);
        hud.AddCircle(node.position + (node.rotation * Vector3(70 + lastImput.y * 10,-35 + lastImput.x * 10,100)),node.rotation * Vector3(0,0,1), 1 ,hudcol,8 , false);
        Vector2 lastImputMapped = MapInput(lastImput);
        hud.AddCircle(node.position + (node.rotation * Vector3(70 + lastImputMapped.y * 10,-35 + lastImputMapped.x * 10,100)),node.rotation * Vector3(0,0,1), 1 ,hudcol2,8 , false);
        
        //hud.AddLine(node.position + (node.rotation * Vector3(60,-35 + 10,100)), node.position + (node.rotation * Vector3(60 - 0.25 * 500,-35 + 10,100)), hudcol,false);
        //hud.AddLine(node.position + (node.rotation * Vector3(60,-35 - 10,100)), node.position + (node.rotation * Vector3(60 - 0.25 * 500,-35 - 10,100)), hudcol,false);
        
        hud.AddLine(node.position + (node.rotation * Vector3(0,0,100)), node.position + AimVec * 100, hudcol,false);
        
        hud.AddCircle(node.position + (node.rotation * Vector3(0,0,100)),AimVec, 20 ,hudcol,32 , false);
        
        for (int i=0; i<499; i++)
        {
            hud.AddLine(node.position + (node.rotation * Vector3(60 - 0.25 * i ,-35 + 10 * lgraph[i].x,100)),
                        node.position + (node.rotation * Vector3(60 - 0.25 * (i+1),-35 + 10 * lgraph[i+1].x,100)), hudcol,false);
            hud.AddLine(node.position + (node.rotation * Vector3(60 - 0.25 * i ,-35 + 10 * lgraph[i].y,100)),
                        node.position + (node.rotation * Vector3(60 - 0.25 * (i+1),-35 + 10 * lgraph[i+1].y,100)), hudcol,false);
            Vector2 mpinp = MapInput(lgraph[i]);
            Vector2 mpinp2 = MapInput(lgraph[i+1]);
            hud.AddLine(node.position + (node.rotation * Vector3(60 - 0.25 * i ,-35 + 10 * mpinp.x,100)),
                        node.position + (node.rotation * Vector3(60 - 0.25 * (i+1),-35 + 10 * mpinp2.x,100)), hudcol2,false);
            hud.AddLine(node.position + (node.rotation * Vector3(60 - 0.25 * i ,-35 + 10 * mpinp.y,100)),
                        node.position + (node.rotation * Vector3(60 - 0.25 * (i+1),-35 + 10 * mpinp2.y,100)), hudcol2,false);
        }
        
    }
        
}
