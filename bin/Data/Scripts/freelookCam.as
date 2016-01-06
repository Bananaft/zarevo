class freelookCam : ScriptObject
{
float yaw = 0.0f; // Camera yaw angle
float pitch = 0.0f; // Camera pitch angle
float roll = 0.0f;
Node@ cameraNode;

void Init(Node node)
    {
        cameraNode = node;
        cameraNode.position = Vector3(0,150,0);
    }
    
void Update(float timeStep)
	{
        // Do not move if the UI has a focused element (the console)
        if (ui.focusElement !is null)
            return;
        Camera@ cam = cameraNode.GetComponent("camera");
        // Movement speed as world units per second
        float MOVE_SPEED;
        if (input.keyDown[KEY_SHIFT]) MOVE_SPEED = 1200.0f; else MOVE_SPEED = 20.0f;
        // Mouse sensitivity as degrees per pixel
        const float MOUSE_SENSITIVITY = 0.1 * 1/cam.zoom;
      
        // Read WASD keys and move the camera scene node to the corresponding direction if they are pressed
        if (input.keyDown['W'])
            cameraNode.Translate(Vector3(0.0f, 0.0f, 1.0f) * MOVE_SPEED * timeStep);
        if (input.keyDown['S'])
            cameraNode.Translate(Vector3(0.0f, 0.0f, -1.0f) * MOVE_SPEED * timeStep);
        if (input.keyDown['A'])
            cameraNode.Translate(Vector3(-1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
        if (input.keyDown['D'])
            cameraNode.Translate(Vector3(1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
        if (input.keyDown['Q'])
            roll += 45 * timeStep;
        else 
            roll = 0.0;
            
            
            
            // Use this frame's mouse motion to adjust camera node yaw and pitch. Clamp the pitch between -90 and 90 degrees
        IntVector2 mouseMove = input.mouseMove;
        yaw += MOUSE_SENSITIVITY * mouseMove.x;
        pitch += MOUSE_SENSITIVITY * mouseMove.y;
        pitch = Clamp(pitch, -90.0f, 90.0f);
        
         // Construct new orientation for the camera scene node from yaw and pitch. Roll is fixed to zero
        cameraNode.rotation = Quaternion(pitch, yaw, roll);
        
        int mousescroll = input.mouseMoveWheel;
        cam.zoom = Clamp(cam.zoom + mousescroll * cam.zoom * 0.2, 0.8 , 20.0 );
        
        //check terrain collision
       // Vector3 campos = cameraNode.position;
        //float ter_height = terrain.GetHeight(campos) + 0.9;
        //if (campos.y<ter_height) cameraNode.position = Vector3(campos.x, ter_height, campos.z);
    }
    
void FixedUpdate(float timeStep)
	{

    }
    
}