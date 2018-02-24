using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;

namespace GOEGame
{

    class ActorAction : ScenarioAction
    {
        [DisplayName("名称")]
        [Category("基础信息")]
        public string prefab { get; set; }
        [Category("基础信息")]
        [DisplayName("动作")]
        [Description("战斗NPC指令只能使用：播放ACT，转向和移动，请不要使用其他指令")]
        public ScenarioNPCActions action { get; set; }
        [DisplayName("阵营")]
        [Category("基础信息")]
        public ScenarioFaction selfFaction { get; set; }
        string param;
        [Category("位置")]
        public float X { get; set; }

        [Category("位置")]
        public float Y { get; set; }
        [DisplayName("播放特效")]
        public string ACTName { get; set; }

        [DisplayName("目标阵营")]
        [Category("目标")]
        public ScenarioFaction Faction { get; set; }
        [DisplayName("目标名称")]
        [Category("目标")]
        public string ObjectID { get; set; }
        [DisplayName("等待移动结束")]
        [Category("移动")]
        public bool WaitMove { get; set; }
        [DisplayName("移动时维持原动作")]
        [Category("移动")]
        public bool KeepAnim { get; set; }
        [DisplayName("移动速度")]
        [Category("移动")]
        [Description("如果速度为-1，则为默认速度")]
        public float Speed { get; set; }
        
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Actor; }
        }

        public override void Parse(string val)
        {
            string[] to = val.Split('|');
            action = (ScenarioNPCActions)int.Parse(to[0]);
            selfFaction = (ScenarioFaction)int.Parse(to[1]);
            prefab = to[2];
            param = to.Length > 3 ? to[3] : null;

            switch (action)
            {
                case ScenarioNPCActions.播放Act:
                    {
                        ACTName = param;
                    }
                    break;
                case ScenarioNPCActions.转向:
                    {
                        string[] t = param.Split(':');
                        Faction = (ScenarioFaction)int.Parse(t[0]);
                        ObjectID = t[1];
                    }
                    break;
                case ScenarioNPCActions.移动:
                    {
                        string[] t = param.Split(':');
                        WaitMove = t.Length > 2 && t[2] == "1";
                        KeepAnim = t.Length > 3 && t[3] == "1";
                        Speed = t.Length > 4 ? float.Parse(t[4]) : -1;
                        X = float.Parse(t[0]);
                        Y = float.Parse(t[1]);
                    }
                    break;
            }
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("战斗NPC指令：");
            sb.Append(action.ToString());
            sb.Append(" 阵营:");
            sb.Append(selfFaction);
            sb.Append(" 名称：");
            sb.Append(prefab);
            string param = "";
            switch (action)
            {
                case ScenarioNPCActions.播放Act:
                    {
                        param = string.Format("特效:{0}", ACTName);
                    }
                    break;
                case ScenarioNPCActions.转向:
                    {
                        param = string.Format("目标阵营:{0} 目标名:{1}", Faction, ObjectID);
                    }
                    break;
                case ScenarioNPCActions.移动:
                    {
                        param = string.Format("坐标:{0},{1} 等待移动:{2} 维持原动作:{3} 移动速度:{4}", X, Y, WaitMove, KeepAnim, Speed);
                    }
                    break;
            }
            sb.Append(" ");
            sb.Append(param);
            return sb.ToString();
        }

        /*protected override void DoAction()
        {
            LinkedList<SceneActorController> list = Functions.Scenario.GetActorByFaction.SafeInvoke(faction, objectID);      
            switch (action)
            {
                case ScenarioNPCActions.PlayAct:
                    foreach (SceneActorController i in list)
                        i.Actor.PlayAct(param);
                    DoFinish();
                    break;
                case ScenarioNPCActions.TurnTo:
                    {
                        string[] t = param.Split(':');
                        ScenarioFaction f = (ScenarioFaction)int.Parse(t[0]);
                        string o = f != ScenarioFaction.Camera ? t[1] : null;
                        SceneActorController actor = list.First.Value;
                        if (f == ScenarioFaction.Camera)
                        {
                            Vector3 dst = Camera.main.transform.position;
                            dst.y = actor.Owner.GameObject.transform.position.y;
                            actor.Owner.GameObject.transform.LookAt(dst);
                        }
                        else
                        {
                            LinkedList<SceneActorController> targets;
                            targets = Functions.Scenario.GetActorByFaction.SafeInvoke(f, o);
                            actor.Owner.GameObject.transform.LookAt(targets.First.Value.Owner.GameObject.transform);
                        }
                    }
                    DoFinish();
                    break;
                case ScenarioNPCActions.Move:
                    {
                        string[] t = param.Split(':');
                        bool waitMove = t.Length > 2 && t[2] == "1";
                        msg.DVector2 vec = new msg.DVector2();
                        vec.x = float.Parse(t[0]);
                        vec.y = float.Parse(t[1]);
                        Vector3 tar = VectorUtil.V2toSceneV3(vec);
                        SceneActorController actor = list.First.Value;
                        //actor.Actor.MoveSpeed = 9;
                        if (waitMove)
                            actor.Actor.MoveTo(tar, () => DoFinish());
                        else
                        {
                            actor.Actor.MoveTo(tar);
                            DoFinish();
                        }
                    }
                    break;
                default:
                    DoFinish();
                    break;

            }
            //DoFinish();
        }

        public void Finish()
        {
            DoFinish();
        }*/
    }
}
