using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class QuakeAction : ScenarioAction
    {
        [DisplayName("震动力度")]
        public float force { get; set; }
        [DisplayName("震动频率")]
        public float spring { get; set; }
        [DisplayName("衰减")]
        public float attenuation { get; set; }
        [DisplayName("持续时间")]
        public float time { get; set; }
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Quake; }
        }

        public override void Parse(string val)
        {
            string[] param = val.Split('|');
            force = float.Parse(param[0]);
            spring = float.Parse(param[1]);
            attenuation = float.Parse(param[2]);
            time = float.Parse(param[3]);
        }

        public override string ToString()
        {
            return string.Format("震屏 力度：{0} 频率:{1} 衰减:{2} 持续时间:{3}", force, spring, attenuation, time);
        }
    }
}
