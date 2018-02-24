using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
namespace GOEGame
{
    class CameraAction : ScenarioAction
    {
        public enum CameraActionTypes
        {
            重置参数,
            设置参数,
            切换聚焦目标,
            重置聚焦目标,
        }
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.Camera; }
        }
        [DisplayName("摄像机指令")]
        public CameraActionTypes type { get; set; }
        [DisplayName("阵营")]
        public ScenarioFaction faction { get; set; }
        [DisplayName("目标名")]
        public string prefab { get; set; }
        [DisplayName("R")]
        public float r { get; set; }
        [DisplayName("Y")]
        public float y { get; set; }
        float angle = float.NaN;
        [DisplayName("角度(Angle)")]
        public float Angle { get { return angle; } set { angle = value; } }
        [DisplayName("时间")]
        public float time { get; set; }
        [DisplayName("向上偏移量")]
        public float offset { get; set; }
        public override void Parse(string val)
        {
            string[] param = val.Split(':');
            type = (CameraActionTypes)int.Parse(param[0]);
            switch (type)
            {
                case CameraActionTypes.重置参数:
                    if (param.Length > 1)
                        time = int.Parse(param[1]) / 1000f;
                    else
                        time = 1f;
                    break;
                case CameraActionTypes.设置参数:
                    r = float.Parse(param[1]);
                    y = float.Parse(param[2]);
                    if (param.Length > 3)
                        time = int.Parse(param[3]) / 1000f;
                    else
                        time = 0;
                    if (param.Length > 4 && !string.IsNullOrEmpty(param[4]))
                    {
                        angle = (float)((float.Parse(param[4]) / Math.PI) * 180f);
                    }
                    if (param.Length > 5)
                    {
                        offset = float.Parse(param[5]);
                        //hasOffset = true;
                    }
                    break;
                case CameraActionTypes.切换聚焦目标:
                    faction = (ScenarioFaction)int.Parse(param[1]);
                    prefab = param[2];
                    if (param.Length > 3)
                        time = float.Parse(param[3]);
                    else
                        time = 0.5f;
                    break;
                case CameraActionTypes.重置聚焦目标:
                    if (param.Length > 1)
                        time = float.Parse(param[1]);
                    else
                        time = 0.5f;
                    break;
            }
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("摄像机指令：");
            sb.Append(type.ToString());
            string param = "";
            switch (type)
            {
                case CameraActionTypes.重置参数:
                    param = string.Format(" 时间：{0}秒", time);
                    break;
                case CameraActionTypes.设置参数:
                    param = string.Format(" R:{0} Y:{1} 角度:{2} 时间:{3}秒 偏移:{4}", r, y, angle, time, offset);
                    break;
                case CameraActionTypes.切换聚焦目标:
                    param = string.Format(" 目标阵营:{0} 目标名:{1} 时间:{2}秒", faction, prefab, time);
                    break;
                case CameraActionTypes.重置聚焦目标:
                    param = string.Format(" 时间：{0}秒", time);
                    break;
            }
            sb.Append(param);
            return sb.ToString();
        }
    }
}
