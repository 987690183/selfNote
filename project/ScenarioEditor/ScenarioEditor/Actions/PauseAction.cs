using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class PauseAction : ScenarioAction
    {
        [DisplayName("是否暂停")]
        public bool Pause { get; set; }
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Pause; }
        }
        public override void Parse(string val)
        {
            Pause = val == "1";
        }

        public override string ToString()
        {
            return Pause ? "暂停" : "解除暂停";
        }
    }
}
