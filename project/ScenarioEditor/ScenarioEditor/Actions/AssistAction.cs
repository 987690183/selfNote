using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using msg;

namespace GOEGame
{
    class AssistAction : ScenarioAction
    {
        [DisplayName("怪物SN")]
        public string monsterSn { get; set; }
        
        public float X { get; set; }
        public float Y { get; set; }
        [DisplayName("出现播放特效")]
        public string appearAct { get; set; }

        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Assist; }
        }

        public override void Parse(string val)
        {
            string[] param = val.Split('|');
            monsterSn = param[0];
            param = param[1].Split(':');
            
            X = float.Parse(param[0]);
            Y = float.Parse(param[1]);
            appearAct = param.Length > 2 ? param[2] : "npc_appear.act.txt";
        }

        public override string ToString()
        {
            return string.Format("助阵武将  怪物SN:{0} 出现位置:{1},{2} 出现播放特效:{3}", monsterSn, X, Y, appearAct);
        }
    }
}
