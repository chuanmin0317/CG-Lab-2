public void CGLine(float x1, float y1, float x2, float y2) {
    // TODO HW1
    // Please paste your code from HW1 CGLine.
    float dx = x2 - x1;
    float dy = y2 - y1;

    int steps;
    if (abs(dx) > abs(dy)){
        steps = (int)abs(dx);
    }else{
        steps = (int)abs(dy);
    }

    if (steps == 0){
        drawPoint(x1, y1, 100);
        return;
    }

    float x_increment = dx / (float(steps));
    float y_increment = dy / (float(steps));

    float x = x1;
    float y = y1;

    for (int i = 0; i <= steps; i++){
        drawPoint(round(x), round(y), 100);
        x += x_increment;
        y += y_increment;
    }
}

public boolean outOfBoundary(float x, float y) {
    if (x < 0 || x >= width || y < 0 || y >= height)
        return true;
    return false;
}

public void drawPoint(float x, float y, color c) {
    int index = (int) y * width + (int) x;
    if (outOfBoundary(x, y))
        return;
    pixels[index] = c;
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

boolean pnpoly(float x, float y, Vector3[] vertexes) {
    // TODO HW2 
    // You need to check the coordinate p(x,v) if inside the vertices. 
    // If yes return true, vice versa.

    int i, j;
    boolean c = false;
    for (i = 0, j = vertexes.length - 1; i < vertexes.length; j = i++) {
        Vector3 vi = vertexes[i];
        Vector3 vj = vertexes[j];
        if (((vi.y > y) != (vj.y > y)) &&
            (x < (vj.x - vi.x) * (y - vi.y) / (vj.y - vi.y) + vi.x)) {
            c = !c;
        }
    }
    return c;
}

public Vector3[] findBoundBox(Vector3[] v) {
    
    
    // TODO HW2 
    // You need to find the bounding box of the vertices v.
    // r1 -------
    //   |   /\  |
    //   |  /  \ |
    //   | /____\|
    //    ------- r2

    if (v.length == 0) {
        return new Vector3[] { new Vector3(0), new Vector3(0) };
    }

    float min_X = v[0].x;
    float max_X = v[0].x;
    float min_Y = v[0].y;
    float max_Y = v[0].y;

    for (int i = 1; i < v.length; i++){
        min_X = min(min_X, v[i].x);
        max_X = max(max_X, v[i].x);
        min_Y = min(min_Y, v[i].y);
        max_Y = max(max_Y, v[i].y);
    }

    Vector3 recordminV = new Vector3(min_X, min_Y, 0);
    Vector3 recordmaxV = new Vector3(max_X, max_Y, 0);
    Vector3[] result = new Vector3[] { recordminV, recordmaxV };
    return result;

}

Vector3 getInterrsection(Vector3 p1, Vector3 p2, float clipV, boolean isX){
    float t = 0.0f;
    Vector3 P_diff = p2.sub(p1);
    if (isX){
        float dx = P_diff.x;
        if (abs(dx) < 1e-6) return p1.copy();
        t = (clipV - p1.x) / dx;
    }else{
        float dy = P_diff.y;
        if (abs(dy) < 1e-6) return p1.copy();
        t = (clipV - p1.y) / dy;
    }

    return p1.add(P_diff.mult(t));
}

public Vector3[] Sutherland_Hodgman_algorithm(Vector3[] points, Vector3[] boundary) {
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    ArrayList<Vector3> output = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i += 1) {
        input.add(points[i]);
    }
 
    // TODO HW2
    // You need to implement the Sutherland Hodgman Algorithm in this section.
    // The function you pass 2 parameter. One is the vertexes of the shape "points".
    // And the other is the vertices of the "boundary".
    // The output is the vertices of the polygon.

    output = input;

    for (int i = 0; i < 4; i++){
        ArrayList<Vector3> newOutput = new ArrayList<Vector3>();
        if (output.size() == 0) break;

        float clipVal;
        boolean isXClip;
        boolean isGreaterSide;

        if (i == 0){
            clipVal = -1.0f;
            isXClip = true;
            isGreaterSide = true;
        } else if (i == 1){
            clipVal = 1.0f;
            isXClip = false;
            isGreaterSide = false;
        } else if (i == 2){
            clipVal = 1.0f;
            isXClip = true;
            isGreaterSide = false;
        } else {
            clipVal = -1.0f;
            isXClip = false;
            isGreaterSide = true;
        }
    

        for (int j = 0; j < output.size(); j++){
            Vector3 P_curr = output.get(j);
            Vector3 P_prev = output.get((j + output.size() - 1) % output.size());

            boolean inside_curr;
            if (isXClip){
                inside_curr = isGreaterSide ? (P_curr.x >= clipVal) : (P_curr.x <= clipVal);
            }else{
                inside_curr = isGreaterSide ? (P_curr.y >= clipVal) : (P_curr.y <= clipVal);
            }

            boolean inside_prev;
            if (isXClip){
                inside_prev = isGreaterSide ? (P_prev.x >= clipVal) : (P_prev.x <= clipVal);
            }else{
                inside_prev = isGreaterSide ? (P_prev.y >= clipVal) : (P_prev.y <= clipVal);
            }

            if (inside_curr){
                if (!inside_prev){
                    newOutput.add(getInterrsection(P_prev, P_curr, clipVal, isXClip));
                }
                newOutput.add(P_curr);
            }else if (inside_prev){
                newOutput.add(getInterrsection(P_prev, P_curr, clipVal, isXClip));
            }
        }
        output = newOutput;
    }

    Vector3[] result = new Vector3[output.size()];
    for (int i = 0; i < result.length; i += 1) {
        result[i] = output.get(i);
    }
    return result;
}
