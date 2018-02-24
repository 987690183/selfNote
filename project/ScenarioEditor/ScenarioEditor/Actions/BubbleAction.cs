using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;
namespace GOEGame
{
    enum ScenarioFaction
    {
        己方单位,
        敌方单位,
        助阵武将,
        剧情NPC,
        主角,
        摄像机,
        己方单位_ID,
        敌方单位_ID,        
    }

    class BubbleAction : ScenarioAction
    {
        [DisplayName("对象ID")]
        public string objectID { get; set; }
        [DisplayName("内容")]
        public string content { get; set; }
        [DisplayName("阵营")]
        public ScenarioFaction faction { get; set; }
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.ChatBubble; }
        }

        public override void Parse(string val)
        {
            string[] param = val.Split(':');
            faction = (ScenarioFaction)int.Parse(param[0]);
            objectID = param[1];
            content = param[2];
        }

        public override string ToString()
        {
            return string.Format("冒泡对话：{0} 的 {1} 说：{2}", faction, objectID, content);
        }
    }
}
