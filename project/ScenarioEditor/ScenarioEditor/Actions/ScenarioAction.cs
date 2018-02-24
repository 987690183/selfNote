using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    enum ScenarioActionTypes
    {
        Dialog,
        Quake,
        Assist,
        BlackScreenText,
        Leave,
        ChangeTeam,
        RestoreTeam,
        ChatBubble,
        NPC,
        Wait,
        Pause,
        Actor,
        Loop,
        EndCombat,
        MainUI,
        HeroAction,
        Camera,
        LockMove,
        OpenUI,
        FinishTask,
        Sound,
    }

    abstract class ScenarioAction
    {
        [Browsable(false)]
        public abstract ScenarioActionTypes Type { get; }

        [Browsable(false)]
        public ScenarioScript Script { get; set; }

        public abstract void Parse(string val);

        [Browsable(false)]
        public ScenarioAction PreviousAction { get; set; }

        [Browsable(false)]
        public ScenarioAction NextAction { get; set; }
        [Browsable(false)]
        public string ScriptText { get; set; }
        [DisplayName("内容")]
        public string Content { get { return ToString(); } }
    }
}
