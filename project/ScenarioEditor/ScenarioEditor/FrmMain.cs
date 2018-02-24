using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using NPOI.SS.UserModel;

namespace ScenarioEditor
{
    public partial class FrmMain : Form
    {
        string lastFile;
        
        public FrmMain()
        {
            InitializeComponent();
        }

        private void btnOpenFile_Click(object sender, EventArgs e)
        {
            if (OD.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                lastFile = OD.FileName;

                IWorkbook workbook= WorkbookFactory.Create(lastFile);
                ISheet sheet = workbook.GetSheetAt(0);
                string[] names = sheet.SheetName.Split('|');
                if (names.Length < 2 || names[1] != "ScenarioConfig")
                {
                    MessageBox.Show("请打开剧情表", "文件错误", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
                lbScripts.Items.Clear();
                for (int i = 4; i < sheet.LastRowNum; i++)
                {
                    IRow row = sheet.GetRow(i);
                    int sn = GetIntFromCell(row, 0);
                    int repID = GetIntFromCell(row, 1);
                    int type =GetIntFromCell(row, 2);
                    int param1 = GetIntFromCell(row, 3);
                    int param2 = GetIntFromCell(row, 4);
                    int param3 = GetIntFromCell(row, 5);
                    bool firstOnly = GetBooleanFromCell(row, 6);
                    bool canSkip = GetBooleanFromCell(row, 7);
                    int delay = GetIntFromCell(row, 9);
                    string content = GetStringFromCell(row, 10);

                    GOEGame.ConfScenarioConfig conf = new GOEGame.ConfScenarioConfig(sn, repID, type, param1, param2, param3, firstOnly, canSkip, delay, content);
                    lbScripts.Items.Add(conf.Script);
                }
            }
        }

        int GetIntFromCell(IRow row, int column)
        {
            ICell cell = row.GetCell(column);
            if (cell == null || string.IsNullOrEmpty(cell.ToString()))
                return 0;
            else
                return int.Parse(cell.ToString());
        }

        bool GetBooleanFromCell(IRow row, int column)
        {
            ICell cell = row.GetCell(column);
            if (cell == null)
                return false;
            else
                return cell.ToString().ToLower() == "true";
        }

        string GetStringFromCell(IRow row, int column)
        {
            ICell cell = row.GetCell(column);
            if (cell == null)
                return "";
            else
                return cell.ToString();
        }

        private void lbScripts_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lbScripts.SelectedItem != null)
            {
                GOEGame.ScenarioScript script = lbScripts.SelectedItem as GOEGame.ScenarioScript;

                pgScript.SelectedObject = script;

                lbActions.Items.Clear();
                foreach(var i in script.actions)
                {
                    lbActions.Items.Add(i);
                }
            }
        }

        private void lbActions_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lbActions.SelectedItem != null)
            {
                GOEGame.ScenarioAction action = lbActions.SelectedItem as GOEGame.ScenarioAction;

                pgAction.SelectedObject = action;
            }
        }
    }
}
