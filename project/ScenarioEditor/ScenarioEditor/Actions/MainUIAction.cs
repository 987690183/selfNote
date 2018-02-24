using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class MainUIAction : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.MainUI; }
        }
        [DisplayName("是否显示主界面")]
        public bool visible { get; set; }
        public override void Parse(string val)
        {
            visible = val == "1";
        }

        public override string ToString()
        {
            return visible ? "显示主界面" : "隐藏主界面";
        }
    }
}
