using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class FinishTaskAction : ScenarioAction
    {
        bool pause;
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.FinishTask; }
        }
        public override void Parse(string val)
        {
           
        }
    }
}
