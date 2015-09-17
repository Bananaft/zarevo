
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
    Array<float> vertexData(numVertices * 6, 0.0f);
    Array<uint16> indexData(numIndexes);
    for (uint16 i = 0; i<pCloud.length; ++i)
    {
        vertexData[i*4*6]     = -1 + pCloud[i].x;
        vertexData[i*4*6+1]   =  0 + pCloud[i].y;
        vertexData[i*4*6+2]   = -1 + pCloud[i].z;
        
        vertexData[i*4*6+6]   =  1 + pCloud[i].x;
        vertexData[i*4*6+7]   =  0 + pCloud[i].y;
        vertexData[i*4*6+8]   = -1 + pCloud[i].z;
        
        vertexData[i*4*6+12]   = -1 + pCloud[i].x;
        vertexData[i*4*6+13]   =  0 + pCloud[i].y;
        vertexData[i*4*6+14]   =  1 + pCloud[i].z;
        
        vertexData[i*4*6+18]   = 1 + pCloud[i].x;
        vertexData[i*4*6+19]   = 0 + pCloud[i].y;
        vertexData[i*4*6+20]   = 1 + pCloud[i].z;
    }
    
    for (uint16 i = 0; i<pCloud.length; ++i)
    {
        indexData[i*6]   = i*4 + 2;
        indexData[i*6+1] = i*4 + 1;
        indexData[i*6+2] = i*4 + 0;
        
        indexData[i*6+3] = i*4 + 3;
        indexData[i*6+4] = i*4 + 1;
        indexData[i*6+5] = i*4 + 2;
    }
    
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
    ib.SetSize(numIndexes, false);
    temp.Clear();
    for (uint i = 0; i < numIndexes; ++i)
        temp.WriteUShort(indexData[i]);
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
