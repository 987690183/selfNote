namespace ScenarioEditor
{
    partial class FrmMain
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmMain));
            this.ts = new System.Windows.Forms.ToolStrip();
            this.btnOpenFile = new System.Windows.Forms.ToolStripButton();
            this.btnSave = new System.Windows.Forms.ToolStripButton();
            this.OD = new System.Windows.Forms.OpenFileDialog();
            this.lbScripts = new System.Windows.Forms.ListBox();
            this.pgScript = new System.Windows.Forms.PropertyGrid();
            this.lbActions = new System.Windows.Forms.ListBox();
            this.pgAction = new System.Windows.Forms.PropertyGrid();
            this.ts.SuspendLayout();
            this.SuspendLayout();
            // 
            // ts
            // 
            this.ts.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.btnOpenFile,
            this.btnSave});
            this.ts.Location = new System.Drawing.Point(0, 0);
            this.ts.Name = "ts";
            this.ts.Size = new System.Drawing.Size(1242, 25);
            this.ts.TabIndex = 0;
            this.ts.Text = "toolStrip1";
            // 
            // btnOpenFile
            // 
            this.btnOpenFile.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnOpenFile.Image = ((System.Drawing.Image)(resources.GetObject("btnOpenFile.Image")));
            this.btnOpenFile.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnOpenFile.Name = "btnOpenFile";
            this.btnOpenFile.Size = new System.Drawing.Size(72, 22);
            this.btnOpenFile.Text = "打开剧情表";
            this.btnOpenFile.Click += new System.EventHandler(this.btnOpenFile_Click);
            // 
            // btnSave
            // 
            this.btnSave.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnSave.Image = ((System.Drawing.Image)(resources.GetObject("btnSave.Image")));
            this.btnSave.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(60, 22);
            this.btnSave.Text = "保存修改";
            // 
            // OD
            // 
            this.OD.Filter = "*.xlsx|*.xlsx";
            // 
            // lbScripts
            // 
            this.lbScripts.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.lbScripts.FormattingEnabled = true;
            this.lbScripts.ItemHeight = 12;
            this.lbScripts.Location = new System.Drawing.Point(10, 31);
            this.lbScripts.Name = "lbScripts";
            this.lbScripts.Size = new System.Drawing.Size(290, 568);
            this.lbScripts.TabIndex = 1;
            this.lbScripts.SelectedIndexChanged += new System.EventHandler(this.lbScripts_SelectedIndexChanged);
            // 
            // pgScript
            // 
            this.pgScript.Location = new System.Drawing.Point(306, 31);
            this.pgScript.Name = "pgScript";
            this.pgScript.Size = new System.Drawing.Size(553, 291);
            this.pgScript.TabIndex = 2;
            // 
            // lbActions
            // 
            this.lbActions.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.lbActions.FormattingEnabled = true;
            this.lbActions.ItemHeight = 12;
            this.lbActions.Location = new System.Drawing.Point(308, 328);
            this.lbActions.Name = "lbActions";
            this.lbActions.Size = new System.Drawing.Size(551, 268);
            this.lbActions.TabIndex = 3;
            this.lbActions.SelectedIndexChanged += new System.EventHandler(this.lbActions_SelectedIndexChanged);
            // 
            // pgAction
            // 
            this.pgAction.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.pgAction.Location = new System.Drawing.Point(865, 31);
            this.pgAction.Name = "pgAction";
            this.pgAction.Size = new System.Drawing.Size(376, 570);
            this.pgAction.TabIndex = 4;
            // 
            // FrmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1242, 613);
            this.Controls.Add(this.pgAction);
            this.Controls.Add(this.lbActions);
            this.Controls.Add(this.pgScript);
            this.Controls.Add(this.lbScripts);
            this.Controls.Add(this.ts);
            this.Name = "FrmMain";
            this.Text = "Form1";
            this.ts.ResumeLayout(false);
            this.ts.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolStrip ts;
        private System.Windows.Forms.ToolStripButton btnOpenFile;
        private System.Windows.Forms.ToolStripButton btnSave;
        private System.Windows.Forms.OpenFileDialog OD;
        private System.Windows.Forms.ListBox lbScripts;
        private System.Windows.Forms.PropertyGrid pgScript;
        private System.Windows.Forms.ListBox lbActions;
        private System.Windows.Forms.PropertyGrid pgAction;
    }
}

