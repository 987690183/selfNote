using UnityEngine;
using UnityEditor;
using Effect = UILabel.Effect;


public class ClientColorConfig
{
    public enum ClientColor
    {
        米色,
        灰色,
        白色,
        绿色,
        蓝色,
        紫色,
        橙色,
        红色,
        金色,
        棕色,
    }

    public static Color calColor(ClientColor tmpColor)
    {
        switch (tmpColor)
        {
            case ClientColor.白色:
                return new Color(1f, 1f, 1f, 1f);
                break;
            case ClientColor.橙色:
                return new Color(255 / 255f, 156 / 255f, 85 / 255f);
                break;
            case ClientColor.红色:
                return new Color(243 / 255f, 67 / 255f, 67 / 255f);
                break;
            case ClientColor.灰色:
                return new Color(189 / 255f, 193 / 255f, 198 / 255f);
                break;
            case ClientColor.金色:
                return new Color(255 / 255f, 234 / 255f, 68 / 255f);
                break;
            case ClientColor.蓝色:
                return new Color(54 / 255f, 230 / 255f, 255 / 255f);
                break;
            case ClientColor.绿色:
                return new Color(168 / 255f, 236 / 255f, 51 / 255f);
                break;
            case ClientColor.米色:
                return new Color(239 / 255f, 223 / 255f, 187 / 255f);
                break;
            case ClientColor.紫色:
                return new Color(255 / 255f, 105 / 255f, 251 / 255f);
                break;
            case ClientColor.棕色:
                return new Color(88 / 255f, 23 / 255f, 6 / 255f);
                break;
            default:
                return new Color(255 / 255f, 105 / 255f, 251 / 255f);
                break;
        }
        return new Color(255 / 255f, 105 / 255f, 251 / 255f);
    }
}

/// <summary>
/// 根据鼠标点中的对象批量修改所有UI字体脚本，脚本位于Editor文件夹
/// </summary>
public class ChangeFontWindow : EditorWindow
{
    //是否改变当前字体
    private static bool isChangFont = false;
    //当前字体
    private static Font curFont;
    //是否改变字体类型
    private static bool isChangeStyle = false;
    //字体类型
    private static FontStyle curFontStyle;
    //是否改变字体大小
    private static bool isChangeSize = false;
    //字体大小
    private static int beforFontSize = 0;
    private static int nowFontSize = 0;
    //是否改变颜色
    private static bool isChangeColor = false;
    //是否自己填写
    private static bool isSelfWrite = false;
    private static ClientColorConfig.ClientColor beforColor = ClientColorConfig.ClientColor.米色;
    private static ClientColorConfig.ClientColor nowColor = ClientColorConfig.ClientColor.米色;
    private static Color selfColor = new Color(0, 0, 0);
    //是否改变阴影特效
    private static bool isChangeEffect = false;
    private static Effect fontEffect;
    private static bool isGradientApply = false;
    private static bool isSetGradientApply = false;

    //window菜单下
    [MenuItem("Custom/Edit label")]
    private static void ShowWindow()
    {
        ChangeFontWindow cw = GetWindow<ChangeFontWindow>(true, "修改字体");
        cw.minSize = new Vector2(440, 500);
        cw.maxSize = new Vector2(550, 500);
    }

    private void OnGUI()
    {
        //向下空出5个像素
        GUILayout.Space(8);
        //创建是否改变当前字体开关
        isChangFont = EditorGUILayout.Toggle("是否改变当前字体", isChangFont);
        GUILayout.Space(5);
        //如果改变当前字体则创建字体文件选择框
        if(isChangFont)
        {
            if (NGUIEditorTools.DrawPrefixButton("Font", GUILayout.Width(64f)))
            {
                ComponentSelector.Show<Font>(OnNGUIFont);
            }
            curFont = (Font)EditorGUILayout.ObjectField("", curFont, typeof(Font), true);
            GUILayout.Space(5);

        }

        //创建是否改变字体类型开关
        isChangeStyle = EditorGUILayout.Toggle("是否改变字体类型", isChangeStyle);
        GUILayout.Space(5);
        //如果改变，则创建字体类型的枚举下拉框
        if(isChangeStyle)
        {
            curFontStyle = (FontStyle)EditorGUILayout.EnumPopup("字体类型", curFontStyle);
            GUILayout.Space(5);
        }

        //创建是否增加字体大小的开关
        isChangeSize = EditorGUILayout.Toggle("是否设置字体大小", isChangeSize);
        GUILayout.Space(5);
        if (isChangeSize)
        {
            //fontSize = EditorGUILayout.IntField(fontSize, GUI.skin.textArea,
            //                    GUILayout.Height(20f), GUILayout.Width(Screen.width - 100f));
            beforFontSize = EditorGUILayout.IntField("被替换的字体大小", beforFontSize);
            GUILayout.Space(5);
            nowFontSize = EditorGUILayout.IntField("替换后的字体大小", nowFontSize);
            GUILayout.Space(5);
        }

        isChangeEffect = EditorGUILayout.Toggle("是否改变阴影特效", isChangeEffect);
        GUILayout.Space(5);
        if (isChangeEffect)
        {
            fontEffect = (UILabel.Effect)EditorGUILayout.EnumPopup("阴影特效", fontEffect);
            GUILayout.Space(5);
        }

        isSetGradientApply = EditorGUILayout.Toggle("是否设置颜色渐变", isSetGradientApply);
        if (isSetGradientApply)
        {
            isGradientApply = EditorGUILayout.Toggle("使用", isGradientApply);
        }

        isChangeColor = EditorGUILayout.Toggle("是否改变颜色", isChangeColor);
        GUILayout.Space(10);
        if (isChangeColor)
        {
            isSelfWrite = EditorGUILayout.Toggle("是否自己填写颜色", isSelfWrite);
            GUILayout.Space(5);
            if (isSelfWrite)
            {
                selfColor = (Color)EditorGUILayout.ColorField("初始的颜色", selfColor);
            }
            else
            {
                beforColor = (ClientColorConfig.ClientColor)EditorGUILayout.EnumPopup("初始的颜色", beforColor);
                GUILayout.Space(8);
            }

            nowColor = (ClientColorConfig.ClientColor)EditorGUILayout.EnumPopup("修改后的颜色", nowColor);
            GUILayout.Space(5);
        }


        //创建确认按钮
        if(GUILayout.Button("确认修改", GUILayout.Height(30), GUILayout.Width(300)))
        {
            Change();
        }
    }

    private void OnNGUIFont(Object obj)
    {
        curFont = obj as Font;
        NGUISettings.ambigiousFont = obj;
        Repaint();
    }

    public static void Change()
    {
        //如果鼠标没有选中物体则返回
        if(Selection.objects == null || Selection.objects.Length == 0) { return; }

        //获取点中对象(包括子目录)所有UILabel组件
        Object[] labels = Selection.GetFiltered(typeof(UILabel), SelectionMode.Deep);

        Debug.Log(labels.Length);
        //赋值
        foreach(Object item in labels)
        {
            UILabel label = (UILabel)item;

            if(isChangFont) { label.trueTypeFont = curFont; }

            if(isChangeStyle) { label.fontStyle = curFontStyle; }

            if (isChangeSize) { 
                if (label.fontSize == beforFontSize){
                    label.fontSize = nowFontSize;
                }
            }

            if (isChangeEffect) { label.effectStyle = fontEffect; }
            if (isSetGradientApply) { label.applyGradient = isGradientApply; }

            //label.applyGradient
            if (isChangeColor) {
                Color tmp1 = new Color(0, 0, 0);
                //如果自己填写颜色
                if (isSelfWrite)
                {
                    tmp1 = selfColor;
                }
                else
                {
                    tmp1 = ClientColorConfig.calColor(beforColor);
                }
                if (label.color == tmp1)
                {
                    label.color = ClientColorConfig.calColor(nowColor);
                }
            }
            EditorUtility.SetDirty(item); //重要(有点像应用设置的意思)
        }
    }
}