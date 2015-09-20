
Array<Vector3> BoxPointCloud (uint amount,Vector3 size)
{
        Array<Vector3> Cloud(amount);
        for(uint i=0; i<amount;i++)
        {
            Cloud[i]=Vector3(0.5 * size.x - Random(size.x),0.5 * size.y - Random(size.y),0.5 * size.z - Random(size.z));
        }
        return Cloud;
}

Geometry@ pCloudToQuadSprites(Array<Vector3> pCloud)
{
    uint numVertices = pCloud.length * 4;
    uint numIndexes = pCloud.length * 6;
    
    VertexBuffer@ vb = VertexBuffer();
    IndexBuffer@ ib = IndexBuffer();
    Geometry@ geom = Geometry();
    
    //vb.shadowed = true;
    vb.SetSize(numVertices, MASK_POSITION|MASK_TEXCOORD1);
    VectorBuffer temp;

    for (uint16 i = 0; i<pCloud.length; ++i)
    {
        temp.WriteFloat( pCloud[i].x);
        temp.WriteFloat( pCloud[i].y);
        temp.WriteFloat( pCloud[i].z);
        temp.WriteFloat(-1);
        temp.WriteFloat(-1);


        temp.WriteFloat( pCloud[i].x);
        temp.WriteFloat( pCloud[i].y);
        temp.WriteFloat( pCloud[i].z);
        temp.WriteFloat(1);
        temp.WriteFloat(-1);

        temp.WriteFloat( pCloud[i].x);
        temp.WriteFloat( pCloud[i].y);
        temp.WriteFloat( pCloud[i].z);
        temp.WriteFloat(-1);
        temp.WriteFloat(1);

        temp.WriteFloat( pCloud[i].x);
        temp.WriteFloat( pCloud[i].y);
        temp.WriteFloat( pCloud[i].z);
        temp.WriteFloat(1);
        temp.WriteFloat(1);
    }
    
    vb.SetData(temp);
    
    //ib.shadowed = true;
    ib.SetSize(numIndexes, false);
    temp.Clear();
    
    for (uint16 i = 0; i<pCloud.length; ++i)
    {
        temp.WriteUShort( i*4 + 2 );
        temp.WriteUShort( i*4 + 1 );
        temp.WriteUShort( i*4 + 0 );
        
        temp.WriteUShort( i*4 + 3 );
        temp.WriteUShort( i*4 + 1 );
        temp.WriteUShort( i*4 + 2 );
    }
    
   ib.SetData(temp);

    geom.SetVertexBuffer(0, vb);
    geom.SetIndexBuffer(ib);
    geom.SetDrawRange(TRIANGLE_LIST , 0, numIndexes);

    return geom;
}

Geometry@ Ribbon(uint16 numVertices)
{
    Array<float> vertexData(numVertices * 6, 0.0f);
    Array<uint16> indexData(numVertices);
    
    for (uint16 i = 0; i<numVertices; ++i)
    {
        
        if (i==0)
        {
            vertexData[0]   = 0;
            vertexData[1] = -1;
            vertexData[2] = 0;
        }else if ((i&1)!=1){
            vertexData[i*6]    = i-1.0;
            vertexData[i*6+1]      = -1;
            vertexData[i*6+2]    = 0;
        } else {
            vertexData[i*6]    = i-1.0;
            vertexData[i*6+1]      = 1;
            vertexData[i*6+2]    = 0;
        }
        
        if (i==numVertices-1) vertexData[i*6] = i-2.0;
    }
    
    for (uint16 i = 0; i<numVertices; ++i) indexData[i] = i;


    VertexBuffer@ vb = VertexBuffer();
    IndexBuffer@ ib = IndexBuffer();
    Geometry@ geom = Geometry();
    
    vb.shadowed = true;
    vb.SetSize(numVertices, MASK_POSITION|MASK_NORMAL);
    VectorBuffer temp;
    for (uint i = 0; i < numVertices * 6; ++i)
        temp.WriteFloat(vertexData[i]);
    vb.SetData(temp);

    ib.shadowed = true;
    ib.SetSize(numVertices, false);
    temp.Clear();
    for (uint i = 0; i < numVertices; ++i)
        temp.WriteUShort(indexData[i]);
    ib.SetData(temp);

    geom.SetVertexBuffer(0, vb);
    geom.SetIndexBuffer(ib);
    geom.SetDrawRange(TRIANGLE_STRIP , 0, numVertices);

    return geom;
}
