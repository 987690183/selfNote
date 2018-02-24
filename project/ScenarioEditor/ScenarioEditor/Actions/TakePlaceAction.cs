using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class TakePlaceAction : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.ChangeTeam; }
        }

        public override void Parse(string val)
        {
        }
    }
}
