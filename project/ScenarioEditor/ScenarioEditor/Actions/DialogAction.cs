using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class DialogAction : ScenarioAction
    {
        [DisplayName("内容")]
        public string content { get; set; }
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Dialog; }
        }
        public override void Parse(string val)
        {
            content = val;
        }

        public override string ToString()
        {
            return "剧情对话：" + content;
        }
    }
}
