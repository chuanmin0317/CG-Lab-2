### 1. Completed Tasks

- [x] Correctly implement the 3 transformation matrices.
- [x] Correctly implement pnpoly.
- [x] Correctly implement the bounding box.
- [x] Correctly implement Sutherland Hodgman Algorithm.
- [x] (Bonus) Implement Super-Sampling for Anti-Aliasing (SSAA).

### 2. Screenshots

**初始介面（或功能展示）**
<img width="1000" height="630" alt="image" src="https://github.com/user-attachments/assets/85031c92-471e-4079-82b5-bff3dbff9d24" />


**形狀變換（旋轉/縮放/平移）**
<img width="999" height="632" alt="image" src="https://github.com/user-attachments/assets/7c936273-4f39-4fca-8b0c-957bad05d9b1" />


**裁剪效果（或 SSAA 反鋸齒效果）**
<img width="999" height="629" alt="image" src="https://github.com/user-attachments/assets/ec67f16b-9c61-434f-b73d-57308b59300e" />


### 3. How Tasks Were Completed

#### 基礎幾何與光柵化

- **CGLine (DDA 演算法):** 沿用 HW1 的數位差分分析器 (DDA) 演算法。

- **Find Bounding Box (`findBoundBox`):** 實作了尋找軸對齊邊界框的功能。透過遍歷多邊形的所有頂點，分別記錄所有 $X$ 座標中的最小值 ($\text{min} X$)、最大值 ($\text{max} X$)，以及所有 $Y$ 座標中的最小值 ($\text{min} Y$)、最大值 ($\text{max} Y$)，從而定義出像素填充的掃描範圍。
```Java
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
```
- **Pnpoly (Point in Polygon - 射線法):** 使用射線投射演算法 (Ray Casting Algorithm)。從待測試點 $(x, y)$ 發射一條水平射線（例如向右），並計算該射線與多邊形所有邊的交點數量。如果交點數為**奇數**，則點在多邊形**內部**；若為**偶數**，則點在多邊形**外部**。此方法用於精確判斷哪些像素點需要被填充。
```Java
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
```
#### 變換矩陣 (Transformation Matrices)

所有變換均使用 $4 \times 4$ 齊次坐標矩陣實現，並透過矩陣乘法來完成組合變換：

- **Translation (`makeTrans`):** 使用標準平移矩陣，將平移向量 $(t_x, t_y, t_z)$ 放置在矩陣的第四列 ($m[3], m[7], m[11]$)。
```Java
  void makeTrans(Vector3 t) {
    // TODO HW2
    // You need to implement the translate matrix here.
    makeIdentity();
    m[3] = t.x;
    m[7] = t.y;
    m[11]= t.z;
  }
```
- **Scale (`makeScale`):** 使用標準縮放矩陣，將縮放因子 $(s_x, s_y, s_z)$ 放置在主對角線 ($m[0], m[5], m[10]$)。
 ```Java
  void makeScale(Vector3 s) {
    // TODO HW2
    // You need to implement the scale matrix here.
    makeIdentity();
    m[0] = s.x;
    m[5] = s.y;
    m[10]= s.z;
  }
  ```
- **RotationZ (`makeRotZ`):** 實作繞 $Z$ 軸旋轉矩陣，將旋轉角度 $\theta$ 的 $\cos\theta$ 和 $\sin\theta$ 元素放置在矩陣的 $2 \times 2$ 左上角，用於 $X-Y$ 平面的旋轉。
 ```Java
  void makeRotZ(float a) {
     // TODO HW2
     // You need to implement the rotation of z-axis matrix here. (Yaw)
    makeIdentity();
    m[0] = cos(a);
    m[1] = -sin(a);
    m[4] = sin(a);
    m[5] = cos(a);
  }
  ```

#### 多邊形裁剪

- **Sutherland-Hodgman Algorithm (`Sutherland_Hodgman_algorithm`):** 實作了針對軸對齊矩形邊界（Canvas 邊界 $[-1, 1]$）的裁剪演算法。該方法依序對多邊形與裁剪視窗的**四條邊**進行處理。對於每條邊，遍歷輸入多邊形的邊，根據線段起點和終點與裁剪邊的關係（Inside/Outside），輸出新的頂點（若線段穿過邊界，則輸出交點），確保最終多邊形完全落在裁剪邊界內。
```Java
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
```
#### 進階渲染 (Advanced Rendering)

- **Super-Sampling Anti-Aliasing (SSAA):** 採用 2x2 超級採樣，在每個螢幕像素內部取 4 個子樣本點 (Sub-samples)，並使用 `pnpoly` 檢查這些子樣本點是否在多邊形內。最終像素的顏色是**形狀顏色**和**背景顏色**的線性混合 (LERP)，混合權重由「內部」子樣本的數量（即覆蓋率）決定，從而實現平滑的邊緣過渡效果。
```Java
float[] offsets = {0.25f, 0.75f};
        int sub_sample_count = 4;

        float shape_intensity = 100.0f;
        float bg_intensity = 255.0f;

        for (int i = int(minmax[0].x); i <= minmax[1].x; i++){
            for (int j = int (minmax[0].y); j <= minmax[1].y; j++){
                int inside_count = 0;

                for (float dx : offsets){
                    for (float dy : offsets){
                        float sub_sample_x = i + dx;
                        float sub_sample_y = j + dy;

                        if (pnpoly(sub_sample_x, sub_sample_y, t_pos)){
                            inside_count++;
                        }
                    }
                }

                if (inside_count > 0){
                    float weight = (float)inside_count / sub_sample_count;

                    float final_intensity = weight * shape_intensity + (1.0f - weight) * bg_intensity;

                    color final_color = color(final_intensity);

                    drawPoint(i, j, final_color);
                }
            }
        }
```
### 4. LLM usage

1.  請求協助完成 HW2 所需的演算法，包括 `makeTrans`, `makeScale`, `makeRotZ` 等變換矩陣的實作細節。
2.  請求協助實作 `findBoundBox`, `pnpoly`, 和 `Sutherland_Hodgman_algorithm` 的演算法邏輯。
3.  請求協助將超級採樣反鋸齒 (SSAA) 邏輯整合到 `drawShape` 函式中，以優化圖像品質。
4.  debug
