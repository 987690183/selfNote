using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GOEGame
{
    class BlackscreenAction : ScenarioAction
    {
        [DisplayName("黑屏维持时间")]
        [Description("如果时间为0则等待玩家点击才继续")]
        public float time { get; set; }
        [DisplayName("是否是白屏")]
        public bool isWhite { get; set; }
        [DisplayName("是否无淡出效果")]
        public bool noFadeOut { get; set; }
        [DisplayName("是否不等待播放结束")]
        public bool noWait { get; set; }
        [DisplayName("内容")]
        public string[] contents { get; set; }
        public override ScenarioActionTypes Type
        {
            get { return ScenarioActionTypes.BlackScreenText; }
        }

        public override void Parse(string val)
        {
            string[] param = val.Split(':');
            time = int.Parse(param[1]) / 1000f;
            if (param.Length > 2)
                isWhite = param[2] == "1";
            if (param.Length > 3)
                noFadeOut = param[3] == "1";
            if (param.Length > 4)
                noWait = param[4] == "1";
            contents = param[0].Replace("\\n","\n").Split('|');
        }

        public override string ToString()
        {
            return string.Format("黑屏文字：{0}", string.Join("\\n", contents));
        }
    }
}
