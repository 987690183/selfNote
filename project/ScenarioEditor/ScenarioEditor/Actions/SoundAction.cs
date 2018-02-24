using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;
namespace GOEGame
{
    class SoundAction : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Sound; }
        }

        [DisplayName("音效名")]
        public string file { get; set; }
        public override void Parse(string val)
        {
            file = val;
        }

        public override string ToString()
        {
            return "播放音效： " + file;
        }
    }
}
