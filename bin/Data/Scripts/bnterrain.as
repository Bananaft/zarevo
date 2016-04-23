class bnterrain : ScriptObject
{
	Texture2D@ renderTexture;
	RenderSurface@ surface;
	
void Init()
	{
		//renderTexture = Texture2D();
		//renderTexture.SetSize(1025, 1025, GetRGBFormat(), TEXTURE_RENDERTARGET);
		//renderTexture.filterMode = FILTER_NEAREST;
		//
		//Scene@ voidscene = Scene();
		//Camera@ Voidcam = node.CreateComponent("Camera");
		
		//Viewport@ rttViewport = Viewport(voidscene, Voidcam);
		//surface.numViewports = 1; 
		//surface.viewports[0] = rttViewport;
		//surface.updateMode = SURFACE_MANUALUPDATE;
		
		Terrain@ terrain = node.CreateComponent("Terrain");
		terrain.spacing = Vector3(5,1.6,5);
		terrain.patchSize = 128;
		terrain.lodBias = 1.2;
		terrain.castShadows = true;
		//terrain.heightMap = renderTexture;
		terrain.heightMap = cache.GetResource("Image", "Textures/geodata/kstn.png");
	}
}