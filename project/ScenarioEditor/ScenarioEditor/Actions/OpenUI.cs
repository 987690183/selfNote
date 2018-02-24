using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class OpenUI : ScenarioAction
    {
        string ui;
        bool wait;
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.OpenUI; }
        }
        public override void Parse(string val)
        {
            string[] param = val.Split(':');
            ui = param[0];
            wait = param.Length > 1 ? param[1] == "1" : false; 
            //bool 
        }
    }
}
