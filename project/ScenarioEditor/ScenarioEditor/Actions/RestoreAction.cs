using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class RestoreAction : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.RestoreTeam; }
        }

        public override void Parse(string val)
        {
        }
    }
}
