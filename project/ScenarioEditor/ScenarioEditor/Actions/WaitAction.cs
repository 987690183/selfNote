using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class WaitAction : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Wait; }
        }
        [DisplayName("等待时间(s)")]
        public float time { get; set; }
        public override void Parse(string val)
        {
            time = float.Parse(val) / 1000f;
        }

        public override string ToString()
        {
            return string.Format("等待 {0:0.##}秒", time);
        }
    }
}
