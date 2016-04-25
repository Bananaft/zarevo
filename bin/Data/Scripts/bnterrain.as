class bnterrain : ScriptObject
{
	Texture2D@ renderTexture;
	RenderSurface@ surface;
	Image@ gtiles;
	Texture2D@ gtex;
	
void Init()
	{
//		renderTexture = Texture2D();
//		renderTexture.SetSize(1025, 1025, GetRGBFormat(), TEXTURE_RENDERTARGET);
//		renderTexture.filterMode = FILTER_NEAREST;
//		
//		Scene@ voidscene = Scene();
//		Camera@ Voidcam = node.CreateComponent("Camera");
//		
//		Viewport@ rttViewport = Viewport(voidscene, Voidcam);
//		surface.numViewports = 1; 
//		surface.viewports[0] = rttViewport;
//		surface.updateMode = SURFACE_MANUALUPDATE;
		
		Terrain@ terrain = node.CreateComponent("Terrain");
		terrain.spacing = Vector3(5,1.6,5);
		terrain.patchSize = 128;
		terrain.lodBias = 1.2;
		terrain.castShadows = true;
		//terrain.heightMap = renderTexture.GetImage();
		terrain.heightMap = cache.GetResource("Image", "Textures/geodata/kstn.png");
		Material@ terrmat = Material();
		terrmat.SetTechnique(0,cache.GetResource("Technique", "Techniques/bn_terrain.xml"),0,0);
		
		gtiles = Image();
		gtiles.SetSize(3072,3072,4);
		
		for (int x=0; x<3050; x++)
		{
			for (int y=0; y<3072; y++)
			{
				gtiles.SetPixel(x,y,Color(Random(1.0/256.0 * 4.0),Random(1.0/256.0 * 8.0),Random(1.0/256.0 * 8.0)));
			}
		}
		
		gtex = Texture2D();
		gtex.SetData(gtiles,true);
		gtex.filterMode = FILTER_NEAREST;
		terrmat.textures[TU_DIFFUSE] = gtex;
		
		Texture2D@ ptex = cache.GetResource("Texture2D", "Textures/patterns/gtiles.png");
		ptex.filterMode = FILTER_NEAREST;
		terrmat.textures[TU_NORMAL] = ptex;
		
		terrain.material = terrmat;
	}
	
void FixedUpdate(float timeStep)
	{
		Viewport@ vp = renderer.viewports[0];
		Camera@ cam = vp.camera;
		
		gtiles.SetPixel(cam.node.worldPosition.x * 5, cam.node.worldPosition.y * 5 ,Color(1.0/256.0 * 8,1.0/256.0 * 8,0))	;
		//gtex.SetData(gtiles,true);
	}
}