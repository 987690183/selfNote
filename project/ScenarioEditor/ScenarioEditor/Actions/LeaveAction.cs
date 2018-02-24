using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using msg;

namespace GOEGame
{
    class LeaveAction : ScenarioAction
    {
        string monsterSn;
        DVector2 pos;
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Leave; }
        }

        public override void Parse(string val)
        {
            string[] param = val.Split('|');
            monsterSn = param[0];
            param = param[1].Split(':');
            pos = new DVector2();
            pos.x = float.Parse(param[0]);
            pos.y = float.Parse(param[1]);
        }
    }
}
