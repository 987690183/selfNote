using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class LockMoveAction : ScenarioAction
    {
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.LockMove; }
        }
        [DisplayName("是否锁定玩家移动")]
        public bool enable { get; set; }
        public override void Parse(string val)
        {
            enable = val == "1";
        }

        public override string ToString()
        {
            return enable ? "锁定玩家移动" : "解除玩家移动锁定";
        }
    }
}
