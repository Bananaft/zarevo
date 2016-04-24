class bnterrain : ScriptObject
{
	Texture2D@ renderTexture;
	RenderSurface@ surface;
	
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
		
		Image@ gtiles = Image();
		gtiles.SetSize(3072,3072,4);
		
		for (int x=0; x<3050; x++)
		{
			for (int y=0; y<3072; y++)
			{
				gtiles.SetPixel(x,y,Color(Random(1),Random(1),Random(1)));
			}
		}
		
		Texture2D@ gtex = Texture2D();
		gtex.SetData(gtiles,true);
		gtex.filterMode = FILTER_NEAREST;
		terrmat.textures[TU_DIFFUSE] = gtex;
		
		terrain.material = terrmat;
	}
}