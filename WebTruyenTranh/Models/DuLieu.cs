using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
namespace WebTruyenTranh.Models
{
    public class BinhLuanViewModel
    {
        public int BinhLuanID { get; set; }
        public string TenDangNhap { get; set; }
        public int? SoChap { get; set; }
        public string NoiDung { get; set; }
        public DateTime NgayDang { get; set; }
    }
    public class BinhLuanContainer
    {
        public List<BinhLuanViewModel> dsBinhLuan { get; set; }

        public BinhLuanContainer(int idTruyen, int? chapID = null)
        {
            dsBinhLuan = new List<BinhLuanViewModel>();
            string strcon = @"data Source=LAPTOP-1T6H7HVR\MSSQLSERVER01; database=WebDocTruyen;User=sa;Password=123";
            using (SqlConnection con = new SqlConnection(strcon))
            {
                string strsel = @"
            SELECT tk.TenDangNhap, c.SoChap, b.NoiDung, b.NgayDang, b.BinhLuanID
            FROM BinhLuan b
            JOIN Taikhoan tk ON b.IDNguoiDung = tk.IDNguoiDung
            LEFT JOIN Chap c ON b.IDChap = c.ChapID
            WHERE b.IDTruyen = @IDTruyen";

                if (chapID.HasValue)
                {
                    strsel += " AND b.IDChap = @IDChap";
                }

                strsel += " ORDER BY b.NgayDang DESC";

                SqlCommand cmd = new SqlCommand(strsel, con);
                cmd.Parameters.AddWithValue("@IDTruyen", idTruyen);
                if (chapID.HasValue)
                {
                    cmd.Parameters.AddWithValue("@IDChap", chapID.Value);
                }

                con.Open();
                SqlDataReader rd = cmd.ExecuteReader();
                while (rd.Read())
                {
                    dsBinhLuan.Add(new BinhLuanViewModel
                    {
                        BinhLuanID = Convert.ToInt32(rd["BinhLuanID"]),
                        TenDangNhap = rd["TenDangNhap"].ToString(),
                        SoChap = rd["SoChap"] == DBNull.Value ? null : (int?)Convert.ToInt32(rd["SoChap"]),
                        NoiDung = rd["NoiDung"].ToString(),
                        NgayDang = Convert.ToDateTime(rd["NgayDang"])
                    });
                }
            }
        }
        public void ThemBinhLuan(int idTruyen, int idNguoiDung, string noiDung, int? idChap = null)
        {
            string strcon = @"data Source=LAPTOP-1T6H7HVR\MSSQLSERVER01; database=WebDocTruyen;User=sa;Password=123";
            using (SqlConnection con = new SqlConnection(strcon))
            {
                string strins = @"
            INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDTruyen, IDChap, NgayDang)
            VALUES (@NoiDung, @IDNguoiDung, @IDTruyen, @IDChap, GETDATE())";

                SqlCommand cmd = new SqlCommand(strins, con);
                cmd.Parameters.AddWithValue("@NoiDung", noiDung);
                cmd.Parameters.AddWithValue("@IDNguoiDung", idNguoiDung);
                cmd.Parameters.AddWithValue("@IDTruyen", idTruyen);
                cmd.Parameters.AddWithValue("@IDChap", (object)idChap ?? DBNull.Value);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

}