using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace msg
{
    public partial class DVector2
    {
        public DVector2() { }

        private float _x = default(float);
        public float x
        {
            get { return _x; }
            set { _x = value; }
        }
        public float getX() { return _x; }
        public void setX(float value) { _x = value; }

        private float _y = default(float);
        public float y
        {
            get { return _y; }
            set { _y = value; }
        }
        public float getY() { return _y; }
        public void setY(float value) { _y = value; }

    }
}
