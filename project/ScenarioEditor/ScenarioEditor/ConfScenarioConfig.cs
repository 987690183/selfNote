using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GOEGame
{
    class ConfScenarioConfig
    {
        public readonly int sn;
        public readonly int repID;
        public readonly int trigger;
        public readonly int triggerParam;
        public readonly int triggerParam2;
        public readonly int triggerParam3;
        public readonly bool firstTimeOnly;
        public readonly bool canSkip;
        public readonly int delay;
        public readonly string content;

        public ScenarioScript Script
        {
            get
            {
                ScenarioScript script =new ScenarioScript();
                script.Parse(this);
                return script;
            }
        }

        public ConfScenarioConfig(int sn, int repID, int trigger, int triggerParam, int triggerParam2, int triggerParam3, bool firstTimeOnly,bool canSkip, int delay, string content)
        {
            this.sn = sn;
            this.repID = repID;
            this.trigger = trigger;
            this.triggerParam = triggerParam;
            this.triggerParam2 = triggerParam2;
            this.triggerParam3 = triggerParam3;
            this.firstTimeOnly = firstTimeOnly;
            this.canSkip = canSkip;
            this.delay = delay;
            this.content = content;
        }
    }
}
