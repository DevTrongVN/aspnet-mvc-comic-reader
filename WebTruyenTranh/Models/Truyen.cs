using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebTruyenTranh.Models
{
    public class TruyenTranh
    {
        public int TruyenID { get; set; }
        public string TenTruyen { get; set; }
        public int? IDTacGia { get; set; }
        public string MoTa { get; set; }
        public string AnhBia { get; set; }
        public DateTime NgayCapNhat { get; set; }
        public int? SoChap { get; set; }
        public int? LuotXem { get; set; }
        public string TinhTrang { get; set; }
    }
    
}