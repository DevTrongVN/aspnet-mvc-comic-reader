using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTruyenTranh.Models;
using System.Data;
using System.Data.SqlClient;
namespace WebTruyenTranh.Controllers
{
    public class HomeController : Controller
    {
        QLTruyenDataContext data = new QLTruyenDataContext();
        public ActionResult Index()
        {
            List<Truyen> dstruyen = data.Truyens.ToList();
            return View(dstruyen);
        }
        public ActionResult TheLoai()
        {
            List<TheLoai> dstheloai = data.TheLoais
                                          .OrderBy(tl => tl.TenTheLoai) 
                                          .ToList();

            return View(dstheloai);
        }
        public ActionResult ChiTietTruyen(int ID)
        {
            var user = Session["User"] as Taikhoan;
            bool daTheoDoi = false;

            if (user != null)
            {
                daTheoDoi = data.TruyenTheoDois
                                .Any(t => t.IDNguoiDung == user.IDNguoiDung && t.TruyenID == ID);
            }

            ViewBag.DaTheoDoi = daTheoDoi;

            Truyen s = data.Truyens.FirstOrDefault(item => item.TruyenID == ID);
            if (s == null)
                return HttpNotFound();

            ViewBag.tg = data.TacGias.FirstOrDefault(item => item.IDTacGia == s.IDTacGia);

            ViewBag.tl = (from tl in data.TheLoais
                          join ttl in data.Truyen_TheLoais on tl.TheLoaiID equals ttl.TheLoaiID
                          where ttl.TruyenID == ID
                          select tl).ToList();

            // Lấy danh sách đánh giá
            var danhSachDanhGia = data.DANHGIAs.Where(dg => dg.TruyenID == ID);

            double? soSaoTrungBinh = danhSachDanhGia.Any()
                                     ? danhSachDanhGia.Average(dg => (double)dg.SOSAO)
                                     : (double?)null;

            ViewBag.SoSaoTB = soSaoTrungBinh;
            ViewBag.TongLuotDG = danhSachDanhGia.Count();

            ViewBag.SoChuong = data.Chaps
                                    .Where(i => i.TruyenID == ID)
                                    .OrderByDescending(i => i.SoChap)
                                    .ToList();

            // Đánh giá của riêng user
            if (user != null)
            {
                ViewBag.DanhGiaCuaToi = data.DANHGIAs
                    .FirstOrDefault(i => i.TruyenID == ID && i.IDNguoidung == user.IDNguoiDung);
            }
            else
            {
                ViewBag.DanhGiaCuaToi = null;
            }

            // Truyện gợi ý
            var listTheLoaiIDs = data.TheLoais.Select(tl => tl.TheLoaiID).ToList();
            var truyenCungTheLoaiIDs = data.Truyen_TheLoais
                .Where(ttl => listTheLoaiIDs.Contains(ttl.TheLoaiID))
                .Select(ttl => ttl.TruyenID)
                .Distinct()
                .ToList();

            ViewBag.TruyenCungTL = data.Truyens
                .Where(t => truyenCungTheLoaiIDs.Contains(t.TruyenID) && t.TruyenID != ID)
                .Take(6)
                .ToList();

            return View(s);
        }

        [HttpPost]
        public ActionResult DanhGia(int TruyenID, int Sao)
        {
            var user = Session["User"] as Taikhoan;
            if (user == null)
            {
                TempData["ThongBao"] = "Bạn phải đăng nhập để đánh giá!";
                return RedirectToAction("DangNhap", "Home");
            }

            var danhGia = data.DANHGIAs
                              .FirstOrDefault(d => d.IDNguoidung == user.IDNguoiDung
                                                && d.TruyenID == TruyenID);

            if (danhGia == null)
            {
                DANHGIA dg = new DANHGIA()
                {
                    TruyenID = TruyenID,
                    IDNguoidung = user.IDNguoiDung,
                    SOSAO = Sao,
                    NGAYDANHGIA = DateTime.Now
                };
                data.DANHGIAs.InsertOnSubmit(dg);
                TempData["ThongBao"] = "Đánh giá thành công!";
            }
            else
            {
                danhGia.SOSAO = Sao;
                danhGia.NGAYDANHGIA = DateTime.Now;
                TempData["ThongBao"] = "Cập nhật đánh giá thành công!";
            }

            data.SubmitChanges();
            return RedirectToAction("ChiTietTruyen", new { ID = TruyenID });
        }
        public ActionResult DangKy()
        {
            
            return View(new Taikhoan());
        }
        [HttpPost]
        public ActionResult DangKy(Taikhoan tk, string reMatKhau)
        {
            
            if (string.IsNullOrWhiteSpace(tk.TenDangNhap) || string.IsNullOrWhiteSpace(tk.MatKhau))
            {
                ViewBag.ThongBao = "Tên đăng nhập và mật khẩu không được để trống.";
                return View();
            }

            if (tk.MatKhau != reMatKhau)
            {
                ViewBag.ThongBao = "Mật khẩu nhập lại không khớp!";
                return View();
            }

            var check = data.Taikhoans.FirstOrDefault(u => u.TenDangNhap == tk.TenDangNhap);
            if (check != null)
            {
                ViewBag.ThongBao = "Tên đăng nhập đã tồn tại!";
                return View();
            }
            tk.VaiTro = 2; 
            tk.NgayDangKy = DateTime.Now;
            tk.TrangThai = true;

            data.Taikhoans.InsertOnSubmit(tk);
            data.SubmitChanges();

            ViewBag.ThongBao = "Đăng ký thành công! Hãy đăng nhập.";
            return RedirectToAction("DangNhap", "Home");
        }
        public ActionResult DangNhap()
        {
            return View();
        }
        [HttpPost]
        public ActionResult DangNhap(string TenDangNhap, string MatKhau)
        {
            var tk = data.Taikhoans
                         .FirstOrDefault(u => u.TenDangNhap == TenDangNhap && u.MatKhau == MatKhau && u.TrangThai == true);

            if (tk == null)
            {
                ViewBag.ThongBao = "Sai tên đăng nhập hoặc mật khẩu!";
                return View();
            }

            Session["User"] = tk;
            Session["HoTen"] = tk.HoTen;
            Session["VaiTro"] = tk.VaiTro;

            if (tk.VaiTro == 1)
                return RedirectToAction("Index", "Admin"); 
            else
                return RedirectToAction("Index", "Home"); 
        }


        public ActionResult DangXuat()
        {
            // Xóa thông tin đăng nhập (Session)
            Session.Clear();

            // Chuyển về trang đăng nhập
            return RedirectToAction("DangNhap", "Home");
        }


        public ActionResult TKNC()
        {

            List<TheLoai> dstheloai = data.TheLoais
                                          .OrderBy(tl => tl.TenTheLoai) 
                                          .ToList();

            return View(dstheloai);

        }
        public ActionResult TruyenTheoTacGia(int id)
        {
            var tacGia = data.TacGias.FirstOrDefault(tg => tg.IDTacGia == id);
            if (tacGia == null) return HttpNotFound();

            var truyenList = data.Truyens.Where(t => t.IDTacGia == id)
                                        .OrderByDescending(t => t.NgayCapNhat)
                                        .ToList();

            ViewBag.TieuDe = "Truyện của tác giả: " + tacGia.TenTacGia;
            return View("KetQuaTimKiem", truyenList); // Sử dụng lại View kết quả tìm kiếm
        }
        [HttpPost]
        public ActionResult XLSearch(string tentruyen, List<int> TheLoaiIDs, string tentacgia) // <-- THÊM THAM SỐ tentacgia
        {
            var ketQuaTruyVan = data.Truyens.AsQueryable();

            
            if (!string.IsNullOrWhiteSpace(tentruyen))
            {
                ketQuaTruyVan = ketQuaTruyVan.Where(t => t.TenTruyen.Contains(tentruyen));
            }

            
            if (!string.IsNullOrWhiteSpace(tentacgia))
            {
                
                ketQuaTruyVan = ketQuaTruyVan.Where(t =>
                    t.TacGia.TenTacGia.Contains(tentacgia) 
                );
            }

            if (TheLoaiIDs != null && TheLoaiIDs.Any())
            {
                ketQuaTruyVan = ketQuaTruyVan.Where(t =>
                    data.Truyen_TheLoais
                        .Where(ttl => TheLoaiIDs.Contains(ttl.TheLoaiID))
                        .Select(ttl => ttl.TruyenID)
                        .Contains(t.TruyenID)
                );
            }

            List<Truyen> ketQuaCuoiCung = ketQuaTruyVan
                .OrderByDescending(t => t.LuotXem)
                .ToList();

            if (ketQuaCuoiCung == null)
            {
                ketQuaCuoiCung = new List<Truyen>();
            }

            return View("KetQuaTimKiem", ketQuaCuoiCung);
        }

        public ActionResult KetQuaTimKiem(List<Truyen> ketQuaTruyen)
        {
            if (ketQuaTruyen == null)
            {
                return View(new List<Truyen>());
            }

            return View(ketQuaTruyen);
        }
        public ActionResult TimTheoTL(int ID)
        {
            var truyenIDs = data.Truyen_TheLoais
                .Where(ttl => ttl.TheLoaiID == ID)
                .Select(ttl => ttl.TruyenID)
                .Distinct();
            List<Truyen> danhSachTruyen = data.Truyens
                .Where(t => truyenIDs.Contains(t.TruyenID))
                .OrderByDescending(t => t.NgayCapNhat) 
                .ToList();

            return View("Index", danhSachTruyen);
        }
        public ActionResult AnhChap(int ID, int chapID)
        {
            var truyen = data.Truyens.FirstOrDefault(item => item.TruyenID == ID);
            var chap = data.Chaps.FirstOrDefault(item => item.ChapID == chapID && item.TruyenID == ID);

            if (truyen == null || chap == null)
            {
                return HttpNotFound("Không tìm thấy truyện hoặc chương này.");
            }

            // ----------- BẮT ĐẦU LOGIC CẬP NHẬT LỊCH SỬ ĐỌC -----------
            if (Session["user"] != null)
            {
                var tk = (Taikhoan)Session["user"];
                int idNguoiDung = tk.IDNguoiDung;

                // 1. Tìm lịch sử đọc của truyện này
                var lichSu = data.LichSuDocs.FirstOrDefault(ls => ls.IDNguoiDung == idNguoiDung && ls.TruyenID == ID);

                if (lichSu != null)
                {
                    // 2a. Đã có -> Cập nhật
                    lichSu.ChapID = chapID;
                    lichSu.NgayDocCuoi = DateTime.Now;
                }
                else
                {
                    // 2b. Chưa có -> Thêm mới
                    LichSuDoc moi = new LichSuDoc
                    {
                        IDNguoiDung = idNguoiDung,
                        TruyenID = ID,
                        ChapID = chapID,
                        NgayDocCuoi = DateTime.Now
                    };
                    data.LichSuDocs.InsertOnSubmit(moi);
                }

                try
                {
                    data.SubmitChanges(); // Lưu thay đổi vào DB
                }
                catch (Exception ex)
                {
                    // Có thể ghi log lỗi ở đây
                }
            }
            // ----------- KẾT THÚC LOGIC CẬP NHẬT LỊCH SỬ ĐỌC -----------
            // Lấy tất cả chap (cho dropdown)
            var allChaps = data.Chaps
                               .Where(c => c.TruyenID == ID)
                               .OrderBy(c => c.SoChap)
                               .ToList();

            // Tìm chap Trước và Sau (cho nút điều hướng)
            int currentSoChap = chap.SoChap;
            var prevChap = allChaps.Where(c => c.SoChap < currentSoChap)
                                   .OrderByDescending(c => c.SoChap)
                                   .FirstOrDefault();
            var nextChap = allChaps.Where(c => c.SoChap > currentSoChap)
                                   .OrderBy(c => c.SoChap)
                                   .FirstOrDefault();

            // Lấy danh sách ảnh (Model)
            var dsAnh = data.AnhChaps
                            .Where(t => t.ChapID == chapID)
                            .OrderBy(t => t.SoTrang)
                            .ToList();

            // Truyền tất cả dữ liệu sang View
            ViewBag.Truyen = truyen;
            ViewBag.Chap = chap;
            ViewBag.AllChaps = allChaps;
            ViewBag.PrevChap = prevChap;
            ViewBag.NextChap = nextChap;

            return View(dsAnh);
        }
        [HttpPost]
        public ActionResult TheoDoi(int TruyenID)
        {
            var user = Session["User"] as Taikhoan;
            if (user == null)
            {
                return RedirectToAction("DangNhap", "NguoiDung");
            }

            var td = data.TruyenTheoDois
                         .FirstOrDefault(t => t.IDNguoiDung == user.IDNguoiDung && t.TruyenID == TruyenID);

            if (td != null)
            {
                // Nếu đã theo dõi rồi thì bỏ theo dõi
                data.TruyenTheoDois.DeleteOnSubmit(td);
                data.SubmitChanges();
                TempData["ThongBao"] = "Đã bỏ theo dõi truyện.";
            }
            else
            {
                // Nếu chưa theo dõi thì thêm mới
                TruyenTheoDoi moi = new TruyenTheoDoi
                {
                    IDNguoiDung = user.IDNguoiDung,
                    TruyenID = TruyenID,
                    NgayTheoDoi = DateTime.Now
                };
                data.TruyenTheoDois.InsertOnSubmit(moi);
                data.SubmitChanges();
                TempData["ThongBao"] = "Bạn đã theo dõi truyện này.";
            }

            return RedirectToAction("ChiTietTruyen", new { id = TruyenID });
        }
        public ActionResult TruyenDangTheoDoi()
        {
            // Lấy tài khoản đang đăng nhập
            var user = Session["User"] as Taikhoan;
            if (user == null)
            {
                // Nếu chưa đăng nhập thì chuyển về trang đăng nhập
                return RedirectToAction("DangNhap", "Home");
            }

            // Lấy danh sách các truyện mà user này đang theo dõi
            List<Truyen> dsTTheoDoi = (from td in data.TruyenTheoDois
                                       join t in data.Truyens on td.TruyenID equals t.TruyenID
                                       where td.IDNguoiDung == user.IDNguoiDung
                                       select t).ToList();

            // Trả kết quả ra view "KetQuaTimKiem"
            return View("Index", dsTTheoDoi);
        }

        public ActionResult HienThiBinhLuan(int IDTruyen, int? ChapID = null)
        {
            BinhLuanContainer bl;

            if (ChapID.HasValue)
            {
                // Lấy bình luận chỉ của chap đó
                bl = new BinhLuanContainer(IDTruyen, ChapID.Value);
            }
            else
            {
                // Lấy tất cả bình luận của truyện
                bl = new BinhLuanContainer(IDTruyen);
            }

            ViewBag.IDTruyen = IDTruyen;
            ViewBag.ChapID = ChapID;

            return PartialView("HienThiBinhLuan", bl);
        }

        [HttpPost]
        public ActionResult ThemBinhLuan(int idTruyen, string noiDung, int? idChap)
        {
            var taiKhoan = Session["user"] as WebTruyenTranh.Models.Taikhoan;
            if (taiKhoan == null)
                return Json(new { success = false, message = "Bạn phải đăng nhập để bình luận" });

            int idNguoiDung = taiKhoan.IDNguoiDung;

            // Nếu vẫn null (không gửi ChapID), lấy Chap 1
            if (!idChap.HasValue)
            {
                string strcon = @"Data Source=.;Initial Catalog=WebDocTruyen;Trusted_Connection=True;";
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string strsel = "SELECT TOP 1 ChapID FROM Chap WHERE TruyenID=@IDTruyen ORDER BY SoChap ASC";
                    SqlCommand cmd = new SqlCommand(strsel, con);
                    cmd.Parameters.AddWithValue("@IDTruyen", idTruyen);
                    con.Open();
                    var result = cmd.ExecuteScalar();
                    if (result != null)
                        idChap = Convert.ToInt32(result);
                }
            }

            // Thêm bình luận
            BinhLuanContainer container = new BinhLuanContainer(0);
            container.ThemBinhLuan(idTruyen, idNguoiDung, noiDung, idChap);

            // Redirect về trang phù hợp
            if (!idChap.HasValue)
                return RedirectToAction("ChiTietTruyen", new { ID = idTruyen });
            else
                return RedirectToAction("AnhChap", new { ID = idTruyen, ChapID = idChap.Value });
        }

        public ActionResult LichSuDoc()
        {
            // Kiểm tra đăng nhập
            if (Session["user"] == null)
            {
                return RedirectToAction("DangNhap", "Home"); // Chuyển đến trang đăng nhập
            }

            var tk = (Taikhoan)Session["user"];
            int idNguoiDung = tk.IDNguoiDung;

            // Lấy danh sách lịch sử, sắp xếp theo ngày đọc mới nhất
            // LINQ to SQL sẽ tự động join các bảng (Truyen, Chap) qua khóa ngoại
            var model = data.LichSuDocs
                            .Where(ls => ls.IDNguoiDung == idNguoiDung)
                            .OrderByDescending(ls => ls.NgayDocCuoi)
                            .ToList();

            return View(model);
        }
    }
}
