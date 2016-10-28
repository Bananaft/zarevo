class veh_controller : ScriptObject
{
	
	Node@ vehnode;
	Node@ campivot;
void Init()
    {
        vehnode = node.scene.CreateChild("vehnode");
		campivot = vehnode.CreateChild("campivot");
		node.parent = vehnode;
		
		vehnode.position = Vector3(-200,200,0);
		node.position = Vector3(0,4,-10);
        SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
		
		StaticModel@ boxybox = vehnode.CreateComponent("StaticModel");
		boxybox.model = cache.GetResource("Model", "Models/Box.mdl");
		
    }
	
void Update(float timeStep)
	{
	}
void FixedUpdate(float timeStep)
	{
		vehnode.position += Vector3(0,0,-1);
        Terrain@ terr = scene.GetChild("terrain").GetComponent("terrain");
        vehnode.position = Vector3(vehnode.position.x,terr.GetHeight(vehnode.position) + 0.4,vehnode.position.z);
	}
}


