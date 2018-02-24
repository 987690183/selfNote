using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class LoopAction : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Loop; }
        }

        int times;
        int runTimes;
        ScenarioAction realNextAction;

        public bool Activated { get; set; }
        public override void Parse(string val)
        {
            if (!string.IsNullOrEmpty(val))
                times = int.Parse(val);
        }
    }
}
