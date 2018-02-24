using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class EndCombat : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.EndCombat; }
        }
        bool forceQuit;
        public override void Parse(string val)
        {
            forceQuit = val == "1" || string.IsNullOrEmpty(val);
        }
    }
}
