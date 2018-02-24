using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;

namespace GOEGame
{
    enum ScenarioNPCActions
    {
        创建,
        删除,
        播放Act,
        转向,
        移动,
        等待点击,
        隐藏场景NPC,
        显示场景NPC,
        隐藏其他玩家,
        显示其他玩家,
    }
        
    class NPCAction : ScenarioAction
    {
        [DisplayName("NPC名")]
        [Category("基础信息")]
        public string prefab { get; set; }
        [Category("基础信息")]
        [DisplayName("动作")]
        public ScenarioNPCActions action { get; set; }

        string param;

        [Category("位置")]
        public float X { get; set; }

        [Category("位置")]
        public float Y { get; set; }

        [Category("基础信息")]
        [DisplayName("别名")]
        public string Alias { get; set; }
        [DisplayName("播放特效")]
        public string ACTName { get; set; }

        [DisplayName("延迟")]
        public float Delay { get; set; }
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
        [DisplayName("是否显示等待点击提示UI")]
        [Category("等待点击")]
        public bool UIVisible { get; set; }
        [Category("等待点击")]
        [DisplayName("等待点击提示文字")]
        public string WaitText { get; set; }
        
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.NPC; }
        }

        public override void Parse(string val)
        {
            string[] to = val.Split('|');
            action = (ScenarioNPCActions)int.Parse(to[0]);
            prefab = to.Length > 1 ? to[1] : null;
            param = to.Length > 2 ? to[2] : null;
            switch (action)
            {
                case ScenarioNPCActions.创建:
                    {
                        string[] t = param.Split(':');
                        X = float.Parse(t[0]);
                        Y = float.Parse(t[1]);
                        Alias = t.Length > 2 ? t[2] : null;
                        ACTName = t.Length > 3 ? t[3] : "npc_appear.act.txt";
                    }
                    break;
                case ScenarioNPCActions.删除:
                    {
                        if (!string.IsNullOrEmpty(param))
                        {
                            string[] t = param.Split(':');
                            ACTName = t[0];
                            Delay = t.Length > 1 ? int.Parse(t[1]) / 1000f : 1.4f;                            
                        }
                    }
                    break;
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
                case ScenarioNPCActions.等待点击:
                    {
                        string[] t = param.Split(':');
                        UIVisible = t.Length > 0 ? t[0] == "1" : false;
                        WaitText = t.Length > 1 ? t[1] : null;
                    }
                    break;
            }
        }


        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("NPC指令：");
            sb.Append(action.ToString());
            sb.Append(" NPC名：");
            sb.Append(prefab);
            string param = "";
            switch (action)
            {
                case ScenarioNPCActions.创建:
                    {
                        param = string.Format("X:{0} Y:{1} 别名:{2} 特效:{3}", X, Y, Alias, ACTName);
                    }
                    break;
                case ScenarioNPCActions.删除:
                    {
                        param = string.Format("特效:{0} 延迟:{1}", ACTName, Delay);
                    }
                    break;
                case ScenarioNPCActions.播放Act:
                    {
                        param = string.Format("特效:{0}", ACTName);
                    }
                    break;
                case ScenarioNPCActions.转向:
                    {
                        param = string.Format("阵营:{0} 目标:{1}", Faction, ObjectID);
                    }
                    break;
                case ScenarioNPCActions.移动:
                    {
                        param = string.Format("坐标:{0},{1} 等待移动:{2} 维持原动作:{3} 移动速度:{4}", X, Y, WaitMove, KeepAnim, Speed);
                    }
                    break;
                case ScenarioNPCActions.等待点击:
                    {
                        param = string.Format("显示提示：{0} 提示信息:{1}", UIVisible, WaitText);
                    }
                    break;
            }
            sb.Append(" ");
            sb.Append(param);
            return sb.ToString();
        }
        /*protected override void DoAction()
        {
            try
            {
                switch (action)
                {
                    case ScenarioNPCActions.Create:
                        {
                            string[] t = param.Split(':');
                            msg.DVector2 pos = new msg.DVector2();
                            pos.x = float.Parse(t[0]);
                            pos.y = float.Parse(t[1]);
                            string aliasName = t.Length > 2 ? t[2] : null;
                            string appearAct = t.Length > 3 ? t[3] : "npc_appear.act.txt";
                            Functions.Scenario.CreateScenarioActor.SafeInvoke(prefab, pos, this, appearAct, aliasName);
                        }
                        break;
                    case ScenarioNPCActions.Remove:
                        {
                            if (!string.IsNullOrEmpty(param))
                            {
                                string[] t = param.Split(':');
                                string act = t[0];
                                float time = t.Length > 1 ? int.Parse(t[1]) / 1000f : 1.4f;
                                Functions.Scenario.ScenarioActorPlayAct.SafeInvoke(prefab, act);
                                if (time > 0)
                                {
                                    TimerMod.SetTimeout(() =>
                                    {
                                        Functions.Scenario.RemoveScenarioActor.SafeInvoke(prefab);
                                        DoFinish();
                                    }, time, false, false);
                                }
                                else
                                {
                                    Functions.Scenario.RemoveScenarioActor.SafeInvoke(prefab);
                                    DoFinish();
                                }
                            }
                            else
                            {
                                Functions.Scenario.RemoveScenarioActor.SafeInvoke(prefab);
                                DoFinish();
                            }
                        }
                        break;
                    case ScenarioNPCActions.PlayAct:
                        {
                            Functions.Scenario.ScenarioActorPlayAct.SafeInvoke(prefab, param);
                            DoFinish();
                        }
                        break;
                    case ScenarioNPCActions.TurnTo:
                        {
                            string[] t = param.Split(':');
                            ScenarioFaction faction = (ScenarioFaction)int.Parse(t[0]);
                            string objectID = t[1];
                            IEnumerable<SceneActorController> list = Functions.Scenario.FindScenarioActors.SafeInvoke(prefab);
                            SceneActorController actor = list.FirstOrDefault() as ScenarioObjController;
                            if (faction == ScenarioFaction.Camera)
                            {
                                Vector3 dst = Camera.main.transform.position;
                                dst.y = actor.Owner.GameObject.transform.position.y;
                                actor.Owner.GameObject.transform.LookAt(dst);
                            }
                            else
                            {
                                LinkedList<SceneActorController> targets = Functions.Scenario.GetActorByFaction.SafeInvoke(faction, objectID);
                                if (targets.Count > 0)
                                {
                                    if (actor != null)
                                        actor.Actor.GameObject.transform.LookAt(targets.First.Value.Actor.GameObject.transform);
                                }
                            }

                        }
                        DoFinish();
                        break;

                    case ScenarioNPCActions.Move:
                        {
                            string[] t = param.Split(':');
                            bool waitMove = t.Length > 2 && t[2] == "1";
                            bool keepAnim = t.Length > 3 && t[3] == "1";
                            float speed = t.Length > 4 ? float.Parse(t[4]) : -1;
                            msg.DVector2 vec = new msg.DVector2();
                            vec.x = float.Parse(t[0]);
                            vec.y = float.Parse(t[1]);
                            Vector3 tar = VectorUtil.V2toSceneV3(vec);
                            IEnumerable<SceneActorController> list = Functions.Scenario.FindScenarioActors.SafeInvoke(prefab);
                            ScenarioObjController actor = list.FirstOrDefault() as ScenarioObjController;
                            //actor.Actor.MoveSpeed = 9;
                            if (keepAnim)
                            {
                                if (waitMove)
                                    actor.Actor.MoveStraight(tar, speed, true, true, () => DoFinish());
                                else
                                {
                                    actor.Actor.MoveStraight(tar, speed, true, true);
                                    DoFinish();
                                }
                            }
                            else
                            {
                                if (waitMove)
                                    actor.Actor.MoveTo(tar, () => DoFinish());
                                else
                                {
                                    actor.Actor.MoveTo(tar);
                                    DoFinish();
                                }
                            }
                        }
                        break;
                    case ScenarioNPCActions.WaitClick:
                        {
                            ScenarioObjController actor = Functions.Scenario.FindScenarioActors.SafeInvoke(prefab).FirstOrDefault() as ScenarioObjController;
                            if (actor == null)
                            {
                                DoFinish();
                            }
                            else
                            {
                                string[] t = param.Split(':');
                                bool visible = t.Length > 0 ? t[0] == "1" : false;
                                string txt = t.Length > 1 ? t[1] : null;

                                actor.SetClickUIVisible(visible, txt);
                                actor.ClickAction = () =>
                                {
                                    actor.ClickAction = null;
                                    DoFinish();
                                };
                            }
                        }
                        break;
                    case ScenarioNPCActions.ShowStageNPC:
                        {
                            foreach (var i in SceneActorController.actorDic)
                            {
                                if (i.Value is NpcController)
                                    i.Value.Actor.Visible = true;
                            }
                            DoFinish();
                        }
                        break;
                    case ScenarioNPCActions.HideStageNPC:
                        {
                            foreach (var i in SceneActorController.actorDic)
                            {
                                if (i.Value is NpcController && i.Value.Actor != null)
                                    i.Value.Actor.Visible = false;
                            }
                            DoFinish();
                        }
                        break;
                }
            }
            catch (Exception ex)
            {
                D.error(ex.ToString());
                ChatMod.ShowMessage(string.Format("剧情:{0} 播放出现异常，脚本代码：{1}", Script.ID, ScriptText));
                DoFinish();
            }
            //DoFinish();
        }
        */
        
    }
}
