
Array<Vector3> CubicPointCloud (uint amount,Vector3 size)
{
        Array<Vector3> Cloud(amount);
        for(uint i=0; i<amount;i++)
        {
            Cloud.[i]=Vector3(0.5 * size.x - Random(size.x),0.5 * size.y - Random(size.y),0.5 * size.y - Random(size.y));
        }
        return Cloud;
}