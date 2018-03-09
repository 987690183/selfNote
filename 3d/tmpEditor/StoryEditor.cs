using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Xml;

public class StoryEditor : EditorWindow {
    private Vector2 storyListScrollPos = Vector2.zero;
    private Vector2 stepListScrollPos = Vector2.zero;
    private Vector2 actionListScrollPos = Vector2.zero;
    private int selectIndex = -1;
    private string[] storyList;

    private string configRelativePath = "StreamingAssets/Config/LDB";
    private string luaRelativePath = "StreamingAssets/Lua/config";
    private string configFileName = "data_story";
    private string configFileFullName = "data_story.xml";
    private StoryConfigLoader loader = null;
    private StoryRootNodeVo currenStory = null;
    private bool enableAddAndRemove = false; //是否启用增删

    string rootGroupStyle = "GroupBox";
    string subGroupStyle = "ObjectFieldThumb";

    [MenuItem("Editor/剧情编辑器")]
    private static void open()
    {
        EditorWindow window = GetWindow<StoryEditor>();
        window.Show();
    }

    void Awake()
    {
        string[] searchPaths = {"Assets/" + configRelativePath};
        string[] assets = AssetDatabase.FindAssets(configFileName, searchPaths);
        if (assets.Length > 0)
        {
            string url = "Assets/" + configRelativePath + "/" + configFileFullName;
            FileStream fs = new FileStream(url, FileMode.Open, FileAccess.Read);
            StreamReader sr = new StreamReader(fs);
            sr.BaseStream.Seek(0, SeekOrigin.Begin);
            string xmlStr = sr.ReadToEnd();
            fs.Close();
            sr.Close();
            try
            {
                loader = XMLParser.ParserCommonXML(xmlStr, "StoryConfigLoader") as StoryConfigLoader;
                loader.process();
            }
            catch (System.Exception ex)
            {
                Debuger.LogError("Log XML error:" + configFileFullName + "\n" + ex.Message);
            }
        }
        else
        {
            loader = new StoryConfigLoader();
            loader.process();
        }

        updateStoryList();
    }

    public void OnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        showStoryList();

        showStoryProperties();
        EditorGUILayout.EndHorizontal();
    }

    private void showStoryList()
    {
        EditorGUILayout.BeginVertical("GroupBox", GUILayout.MinWidth(100), GUILayout.MaxWidth(150));
        GUILayout.Label("剧情ID列表");
        using (var scrollView = new EditorGUILayout.ScrollViewScope(storyListScrollPos))
        {
            storyListScrollPos = scrollView.scrollPosition;
            int lastSelectedIndex = selectIndex;
            selectIndex = GUILayout.SelectionGrid(selectIndex, storyList, 1);
            if (lastSelectedIndex != selectIndex)
            {
                clearSelect();
                currenStory = loader.story[selectIndex];
            }
        }

        EditorGUILayout.BeginHorizontal("GroupBox");
        if (GUILayout.Button("新增剧情"))
        {
            clearSelect();

            List<StoryRootNodeVo> tempList = new List<StoryRootNodeVo>(loader.story);
            StoryRootNodeVo vo = new StoryRootNodeVo();
            vo.id = 99999;
            vo.scene = 0;
            tempList.Add(vo);
            loader.story = tempList.ToArray();

            selectIndex = tempList.Count - 1;
            currenStory = vo;

            updateStoryList();
        }

        if (selectIndex > 0)
        {
            if (GUILayout.Button("删除剧情"))
            {
                List<StoryRootNodeVo> tempList = new List<StoryRootNodeVo>(loader.story);
                tempList.RemoveAt(selectIndex);
                loader.story = tempList.ToArray();

                clearSelect();
                selectIndex = -1;
                currenStory = null;

                updateStoryList();
            }
        }
        EditorGUILayout.EndHorizontal();

        if (loader.story.Length > 0)
        {
            if (GUILayout.Button("保存所有配置"))
            {
                if (loader != null)
                {
                    XmlDocument doc = ScriptObject2XML.ParserCommonXML(loader);
                    string xmlPath = Application.dataPath + "/" + configRelativePath + "/" + configFileFullName;
                    doc.Save(xmlPath);

                    Dictionary<string, string> dic = new Dictionary<string, string>();
                    dic.Add("item", "boneId");
                    string content = ScriptObject2Lua.ParserNormalLua(loader, "StoryConfigLoader", dic);
                    string luaPath = "Assets/" + luaRelativePath + "/" + configFileName + ".lua";
                    File.WriteAllText(luaPath, content, System.Text.Encoding.UTF8);
                }

                EditorUtility.DisplayDialog("保存", string.Format("保存成功({0}.xml, {1}.lua)", configFileName, configFileName), "确定");
            }
        }
        EditorGUILayout.EndVertical();
    }

    private void showStoryProperties()
    {
        if (currenStory != null)
        {
            EditorGUILayout.BeginVertical(rootGroupStyle);
            using (var h = new EditorGUILayout.HorizontalScope())
            {
                currenStory.id = EditorGUILayout.IntField("剧情ID：", currenStory.id);
                currenStory.name = EditorGUILayout.TextField("剧情名字：", currenStory.name);
                bool toggle = GUILayout.Toggle(currenStory.scene == 1, "是场景剧情");
                currenStory.scene = toggle ? 1 : 0;
                enableAddAndRemove = GUILayout.Toggle(enableAddAndRemove, "是否启用增删功能");
            }

            if (currenStory.step.Length > 0)
            {
                drawSteps();
            }

            if (enableAddAndRemove && GUILayout.Button("添加剧情步骤"))
            {
                List<StoryXMLNode> tempList = new List<StoryXMLNode>(currenStory.step);
                StoryXMLNode node = new StoryXMLNode();
                tempList.Add(node);
                currenStory.step = tempList.ToArray();
                bShowSteps.Clear();
            }
            EditorGUILayout.EndVertical();
        }
    }

    private List<bool> bShowSteps = new List<bool>();
    private void drawSteps()
    {
        var steps = currenStory.step;
        if (bShowSteps.Count <= 0)
        {
            foreach(var step in steps)
                bShowSteps.Add(true);
        }

        EditorGUILayout.BeginVertical(rootGroupStyle);
        int removeIndex = -1;
        stepListScrollPos = EditorGUILayout.BeginScrollView(stepListScrollPos);
        for (int i = 0; i < steps.Length; ++i )
        {
            EditorGUILayout.BeginVertical(subGroupStyle);
            StoryXMLNode stepNode = steps[i];
            using (var h = new EditorGUILayout.HorizontalScope()) {
                bShowSteps[i] = EditorGUILayout.Foldout(bShowSteps[i], "步骤(" + (i + 1) + ")");
                stepNode.lastTime = EditorGUILayout.FloatField("步骤结束时间：", stepNode.lastTime);
            }
            var actions = stepNode.node;
            if (bShowSteps[i])
            {
                int removeActionIndex = -1;
                for (int j = 0; j < actions.Length; ++j)
                {
                    EditorGUILayout.BeginVertical(subGroupStyle);
                    var action = actions[j];
                    drawAction(action);

                    if (enableAddAndRemove && GUILayout.Button("删除这个Action"))
                    {
                        removeActionIndex = j;
                    }
                    EditorGUILayout.EndVertical();
                }
                if (removeActionIndex >= 0)
                {
                    List<StoryActionNode> tempActionList = new List<StoryActionNode>(actions);
                    tempActionList.RemoveAt(removeActionIndex);
                    stepNode.node = tempActionList.ToArray();
                }
            }

            using (var h = new EditorGUILayout.HorizontalScope())
            {
                if (enableAddAndRemove && GUILayout.Button("添加Action"))
                {
                    List<StoryActionNode> tempActionList = new List<StoryActionNode>(actions);
                    StoryActionNode action = new StoryActionNode();
                    tempActionList.Add(action);
                    stepNode.node = tempActionList.ToArray();
                }
                if (enableAddAndRemove && GUILayout.Button("删除这一步骤"))
                {
                    removeIndex = i;
                }
            }

            EditorGUILayout.EndVertical();
        }

        if (removeIndex >= 0)
        {
            List<StoryXMLNode> tempList = new List<StoryXMLNode>(steps);
            tempList.RemoveAt(removeIndex);
            currenStory.step = tempList.ToArray();
            bShowSteps.Clear();
        }
        EditorGUILayout.EndScrollView();

        EditorGUILayout.EndVertical();
    }

    private List<bool> bShowMonsters = new List<bool>();
    private List<bool> bShowPhotos = new List<bool>();
    private List<bool> bShowTalks = new List<bool>();
    private List<bool> bShowNPCTalks = new List<bool>();
    private void drawAction(StoryActionNode action)
    {
        action.type = EditorGUILayout.TextField("类型：", action.type);
        action.args = EditorGUILayout.TextField("参数：", action.args);
        
        // monsters
        {
            StoryMonster[] monsters = action.Monster;
            if (monsters.Length > 0)
            {
                if (bShowMonsters.Count <= 0)
                {
                    foreach (var monster in monsters)
                        bShowMonsters.Add(true);
                }

                EditorGUILayout.BeginVertical(subGroupStyle);
                int removeIndex = -1;
                for (int i = 0; i < monsters.Length; ++i)
                {
                    //bShowMonsters[i] = EditorGUILayout.Foldout(bShowMonsters[i], "Monsters(" + (i + 1) + ")");
                    //if (bShowMonsters[i])
                    EditorGUILayout.Foldout(true, "Monsters(" + (i + 1) + ")");
                    {
                        EditorGUILayout.BeginVertical(subGroupStyle);
                        var monster = monsters[i];
                        drawMonster(monster);
                        EditorGUILayout.EndVertical();
                    }
                    if (enableAddAndRemove && GUILayout.Button("删除这一个Monster"))
                        removeIndex = i;
                }
                EditorGUILayout.EndVertical();
                if (removeIndex >= 0)
                {
                    var tempList = new List<StoryMonster>(monsters);
                    tempList.RemoveAt(removeIndex);
                    action.Monster = tempList.ToArray();
                }
            }
            if (enableAddAndRemove && StyledButton("添加Monster"))
            {
                List<StoryMonster> tempActionList = new List<StoryMonster>(monsters);
                StoryMonster v = new StoryMonster();
                tempActionList.Add(v);
                action.Monster = tempActionList.ToArray();
            }
        }

        // photos
        {
            var photos = action.Photo;
            if (photos.Length > 0)
            {
                if (bShowPhotos.Count <= 0)
                {
                    foreach (var photo in photos)
                        bShowPhotos.Add(true);
                }

                int removeIndex = -1;
                EditorGUILayout.BeginVertical(subGroupStyle);
                for (int i = 0; i < photos.Length; ++i)
                {
                    //bShowPhotos[i] = EditorGUILayout.Foldout(bShowPhotos[i], "Photos(" + (i + 1) + ")");
                    //if (bShowPhotos[i])
                    EditorGUILayout.Foldout(true, "Photos(" + (i + 1) + ")");
                    {
                        EditorGUILayout.BeginVertical("GroupBox");
                        var photo = photos[i];
                        drawPhotos(photo);
                        EditorGUILayout.EndVertical();
                    }
                    if (enableAddAndRemove && GUILayout.Button("删除这个Photo"))
                        removeIndex = i;
                }
                EditorGUILayout.EndVertical();
                if (removeIndex >= 0)
                {
                    var tempList = new List<PhotoVo>(photos);
                    tempList.RemoveAt(removeIndex);
                    action.Photo = tempList.ToArray();
                }
            }

            if (enableAddAndRemove && StyledButton("添加Photo"))
            {
                List<PhotoVo> tempActionList = new List<PhotoVo>(photos);
                PhotoVo v = new PhotoVo();
                tempActionList.Add(v);
                action.Photo = tempActionList.ToArray();
            }
        }

        // talks
        {
            var talks = action.Talk;
            if (talks.Length > 0)
            {
                if (bShowTalks.Count <= 0)
                {
                    foreach (var talk in talks)
                        bShowTalks.Add(true);
                }

                int removeIndex = -1;
                EditorGUILayout.BeginVertical(subGroupStyle);
                for (int i = 0; i < talks.Length; ++i)
                {
                    //bShowTalks[i] = EditorGUILayout.Foldout(bShowTalks[i], "Talks(" + (i + 1) + ")");
                    //if (bShowTalks[i])
                    EditorGUILayout.Foldout(true, "Talks(" + (i + 1) + ")");
                    {
                        EditorGUILayout.BeginVertical("GroupBox");
                        var talk = talks[i];
                        drawTalk(talk);
                        EditorGUILayout.EndVertical();
                    }
                    if (enableAddAndRemove && GUILayout.Button("删除这个Talk"))
                        removeIndex = i;
                }
                EditorGUILayout.EndVertical();
                if (removeIndex >= 0)
                {
                    var tempList = new List<TalkVo>(talks);
                    tempList.RemoveAt(removeIndex);
                    action.Talk = tempList.ToArray();
                }
            }

            if (enableAddAndRemove && StyledButton("添加Talk"))
            {
                List<TalkVo> tempActionList = new List<TalkVo>(talks);
                TalkVo v = new TalkVo();
                tempActionList.Add(v);
                action.Talk = tempActionList.ToArray();
            }
        }

        // NPCTalks
        {
            var npcTalks = action.NpcTalk;
            if (npcTalks.Length > 0)
            {
                if (bShowNPCTalks.Count <= 0)
                {
                    foreach (var v in npcTalks)
                        bShowNPCTalks.Add(true);
                }

                int removeIndex = -1;
                EditorGUILayout.BeginVertical(subGroupStyle);
                for (int i = 0; i < npcTalks.Length; ++i)
                {
                    //bShowNPCTalks[i] = EditorGUILayout.Foldout(bShowNPCTalks[i], "NPCTalks(" + (i+1)+ ")");
                    //if (bShowNPCTalks[i])
                    EditorGUILayout.Foldout(true, "NPCTalks(" + (i + 1) + ")");
                    {
                        EditorGUILayout.BeginVertical("GroupBox");
                        drawNPCTalk(npcTalks[i]);
                        EditorGUILayout.EndVertical();
                    }
                    if (enableAddAndRemove && GUILayout.Button("删除这个NpcTalk"))
                        removeIndex = i;
                }
                EditorGUILayout.EndVertical();
                if (removeIndex >= 0)
                {
                    var tempList = new List<NpcTalkVo>(npcTalks);
                    tempList.RemoveAt(removeIndex);
                    action.NpcTalk = tempList.ToArray();
                }
            }

            if (enableAddAndRemove && StyledButton("添加NpcTalk"))
            {
                List<NpcTalkVo> tempActionList = new List<NpcTalkVo>(npcTalks);
                NpcTalkVo v = new NpcTalkVo();
                tempActionList.Add(v);
                action.NpcTalk = tempActionList.ToArray();
            }
        }
    }

    private void drawMonster(StoryMonster monster)
    {
        monster.ID = EditorGUILayout.IntField("ID：", monster.ID);
        monster.type = EditorGUILayout.TextField("type：", monster.type);
        monster.player = EditorGUILayout.TextField("player：", monster.player);
        monster.ShowUp = EditorGUILayout.IntField("ShowUp：", monster.ShowUp);
        monster.RotY = EditorGUILayout.FloatField("RotY：", monster.RotY);
        Vector3 pos = new Vector3(monster.PosX, monster.PosY, monster.PosZ);
        pos = EditorGUILayout.Vector3Field("position：", pos);
        monster.PosX = pos.x;
        monster.PosY = pos.y;
        monster.PosZ = pos.z;
    }

    private void drawPhotos(PhotoVo photo)
    {
        photo.lastTime = EditorGUILayout.FloatField("ID：", photo.lastTime);
        photo.name = EditorGUILayout.TextField("name：", photo.name);
        photo.waitTime = EditorGUILayout.FloatField("waitTime：", photo.waitTime);
        photo.position = EditorGUILayout.TextField("position", photo.position);
        photo.size = EditorGUILayout.TextField("size", photo.size);
    }

    private void drawTalk(TalkVo talk)
    {
        talk.lastTime = EditorGUILayout.FloatField("lastTime：", talk.lastTime);
        talk.player = EditorGUILayout.TextField("player：", talk.player);
        talk.action = EditorGUILayout.TextField("action：", talk.action);
        talk.content = EditorGUILayout.TextField("content：", talk.content);
        talk.sound = EditorGUILayout.TextField("sound：", talk.sound);
    }

    private void drawNPCTalk(NpcTalkVo talk)
    {
        talk.lastTime = EditorGUILayout.FloatField("lastTime：", talk.lastTime);
        talk.type = EditorGUILayout.TextField("type：", talk.type);
        talk.action = EditorGUILayout.TextField("action：", talk.action);
        talk.content = EditorGUILayout.TextField("content：", talk.content);
        talk.ID = EditorGUILayout.IntField("ID：", talk.ID);
    }

    private void updateStoryList()
    {
        List<string> tempList = new List<string>();
        foreach (var v in loader.story)
        {
            tempList.Add(v.id.ToString());
        }
        storyList = tempList.ToArray();
    }

    private void clearSelect()
    {
        bShowSteps.Clear();
        bShowMonsters.Clear();
        bShowPhotos.Clear();
        bShowTalks.Clear();
        bShowNPCTalks.Clear();
        currenStory = null;
    }

    public bool StyledButton(string label, string tips = null)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        bool clickResult = GUILayout.Button(new GUIContent(label, tips));
        GUILayout.FlexibleSpace();
        EditorGUILayout.EndHorizontal();
        return clickResult;
    }
}