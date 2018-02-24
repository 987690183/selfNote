using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
namespace GOEGame
{
    enum ScenarioTriggerTypes
    {
        副本开始 = 1,
        战斗开始,
        战斗结束,
        位置,
        己方武将数量达到指定数目,
        地图加载完毕,
        战斗剩余X秒,
        敌方生命百分比,
        带有某任务进入地图,
    }
    class ScenarioScript
    {
        ScenarioAction firstAction;

        [DisplayName("序号")]
        public int ID { get; set; }
        [DisplayName("副本ID")]
        public int CampaignStageID { get; set; }
        [DisplayName("触发时机")]
        public ScenarioTriggerTypes Trigger { get; set; }
        [DisplayName("触发参数")]
        public int TriggerParam { get; set; }
        [DisplayName("触发参数2")]
        public int TriggerParam2 { get; set; }
        [DisplayName("触发参数3")]
        public int TriggerParam3 { get; set; }
        [DisplayName("仅第一次进入该副本时触发")]
        public bool FirstTimeOnly { get; set; }
        [DisplayName("触发延时（ms）")]
        public float Delay { get; set; }

        public List<ScenarioAction> actions = new List<ScenarioAction>();

        public void Parse(ConfScenarioConfig conf)
        {
            CampaignStageID = conf.repID;
            ID = conf.sn;
            Trigger = (ScenarioTriggerTypes)conf.trigger;
            TriggerParam = conf.triggerParam;
            TriggerParam2 = conf.triggerParam2;
            TriggerParam3 = conf.triggerParam3;
            FirstTimeOnly = conf.firstTimeOnly;
            Delay = conf.delay / 1000f;

            System.Text.RegularExpressions.MatchCollection lst = System.Text.RegularExpressions.Regex.Matches(conf.content, "(\\w+?)[[](.*?)([]])");
            ScenarioAction lastAction = null;
            foreach (System.Text.RegularExpressions.Match i in lst)
            {
                int idx = i.Value.IndexOf('[');
                string cmd = i.Value.Substring(0, idx);
                string value = i.Value.Substring(idx + 1, i.Value.Length - idx - 2);
                ScenarioAction action = null;
                switch (cmd.ToUpper())
                {
                    case "D":
                        action = new DialogAction();
                        break;
                    case "Q":
                        action = new QuakeAction();
                        break;
                    case "A":
                        action = new AssistAction();
                        break;
                    case "B":
                        action = new BlackscreenAction();
                        break;
                    case "L":
                        action = new LeaveAction();
                        break;
                    case "T":
                        action = new TakePlaceAction();
                        break;
                    case "P":
                        action = new BubbleAction();
                        break;
                    case "NPC":
                        action = new NPCAction();
                        break;
                    case "W":
                        action = new WaitAction();
                        break;
                    case "PA":
                        action = new PauseAction();
                        break;
                    case "AC":
                        action = new ActorAction();
                        break;
                    case "XH":
                        action = new LoopAction();
                        break;
                    case "JSZD":
                        action = new EndCombat();
                        break;
                    case "CAM":
                        action = new CameraAction();
                        break;
                    case "HERO":
                        action = new HeroAction();
                        break;
                    case "LOCK":
                        action = new LockMoveAction();
                        break;
                    case "UI":
                        action = new MainUIAction();
                        break;
                    case "DKJM":
                        action = new OpenUI();
                        break;
                    case "WCRW":
                        action = new FinishTaskAction();
                        break;
                    case "S":
                        action = new SoundAction();
                        break;
                    default:
                        System.Windows.Forms.MessageBox.Show(string.Format("剧情:{0} 中有无效的指令：\'{1}\'", ID, cmd), "读取错误", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Error);
                        continue;
                }
                value = value.Replace("@n", "\n").Replace('@', '[').Replace('$', ']');
                try
                {
                    action.Parse(value);
                }
                catch
                {
                    System.Windows.Forms.MessageBox.Show(string.Format("剧情:{0} 中有无效的指令：\'{1}\'", ID, i.Value), "读取错误", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Error);                        
                }
                action.Script = this;
                action.ScriptText = i.Value;
                actions.Add(action);

                if (firstAction == null)
                    firstAction = action;
                if (lastAction != null)
                {
                    lastAction.NextAction = action;
                    action.PreviousAction = lastAction;
                }
                lastAction = action;
            }
        }

        public override string ToString()
        {
            return string.Format("SN:{0} RepID:{1}", ID, CampaignStageID);
        }
    }
}
