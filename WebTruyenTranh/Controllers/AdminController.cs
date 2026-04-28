using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTruyenTranh.Models;
using System.IO;
using System.Linq;
namespace WebTruyenTranh.Controllers
{
    public class AdminController : Controller
    {
        //
        // GET: /Admin/
        QLTruyenDataContext data = new QLTruyenDataContext();

        public ActionResult Index()
        {
            var list = data.Truyens.ToList();
            return View(list);
        }

        public ActionResult Them()
        {
            ViewBag.TacGiaList = new SelectList(data.TacGias, "IDTacGia", "TenTacGia");
            var tinhTrangData = new List<SelectListItem>
    {
        new SelectListItem { Value = "Đang tiến hành", Text = "Đang tiến hành" },
        new SelectListItem { Value = "Đã hoàn thành", Text = "Đã hoàn thành" }
    };
            ViewBag.TinhTrangList = new SelectList(tinhTrangData, "Value", "Text");
            List<TheLoai> dsTheLoai = data.TheLoais.OrderBy(tl => tl.TenTheLoai).ToList();
            ViewBag.TheLoaiList = dsTheLoai;
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken] 
        public ActionResult Them(Truyen truyen,
                                     HttpPostedFileBase AnhBiaFile,
                                     List<int> TheLoaiIDs)
        {

            if (AnhBiaFile != null && AnhBiaFile.ContentLength > 0)
            {
                if (AnhBiaFile.ContentType.StartsWith("image/"))
                {
                    string fileName = Path.GetFileName(AnhBiaFile.FileName);
                    string path = Path.Combine(Server.MapPath("~/Content/AnhBia/"), fileName);

                    try
                    {
                        AnhBiaFile.SaveAs(path);
                        truyen.AnhBia = fileName;
                    }
                    catch (Exception ex)
                    {
                        ModelState.AddModelError("", "Lỗi lưu file: " + ex.Message);
                    }
                }
                else
                {
                    ModelState.AddModelError("AnhBia", "Chỉ chấp nhận các tệp hình ảnh.");
                }
            }
            else
            {
                ModelState.AddModelError("AnhBia", "Vui lòng chọn ảnh bìa cho truyện.");
            }

            if (ModelState.IsValid)
            {
                truyen.NgayCapNhat = DateTime.Now;
                truyen.LuotXem = 0;
                truyen.SOCHAP = 0;
                data.Truyens.InsertOnSubmit(truyen);
                data.SubmitChanges(); 

                if (TheLoaiIDs != null && TheLoaiIDs.Any())
                {
                    foreach (var tlID in TheLoaiIDs)
                    {
                        var truyenTheLoai = new Truyen_TheLoai
                        {
                            TruyenID = truyen.TruyenID,
                            TheLoaiID = tlID
                        };
                        data.Truyen_TheLoais.InsertOnSubmit(truyenTheLoai);
                    }
                    data.SubmitChanges();
                }

                return RedirectToAction("Index");
            }

            ViewBag.TacGiaList = new SelectList(data.TacGias, "IDTacGia", "TenTacGia", truyen.IDTacGia);

            var tinhTrangData = new List<SelectListItem>
    {
        new SelectListItem { Value = "Đang tiến hành", Text = "Đang tiến hành" },
        new SelectListItem { Value = "Đã hoàn thành", Text = "Đã hoàn thành" }
    };
            ViewBag.TinhTrangList = new SelectList(tinhTrangData, "Value", "Text", truyen.TinhTrang);

            ViewBag.TheLoaiList = data.TheLoais.OrderBy(tl => tl.TenTheLoai).ToList();


            ViewBag.SelectedTheLoaiIDs = TheLoaiIDs ?? new List<int>();

            return View(truyen);
        }

        public ActionResult ThemChap()
        {
            ViewBag.TruyenList = new SelectList(data.Truyens.OrderBy(t => t.TenTruyen), "TruyenID", "TenTruyen");

            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThemChap(Chap chap, IEnumerable<HttpPostedFileBase> AnhChapFiles)//Nhận một danh sách các file ảnh upload lên
        {
            // 1. Auto tăng SoChap
            if (chap.TruyenID > 0)
            {
                int soChapHienTai = data.Chaps
                                       .Where(c => c.TruyenID == chap.TruyenID)
                                       .Select(c => (int?)c.SoChap)
                                       .Max() ?? 0;

                chap.SoChap = soChapHienTai + 1;
            }

            if (!ModelState.IsValid)
            {
                ViewBag.TruyenList = new SelectList(data.Truyens.OrderBy(t => t.TenTruyen), "TruyenID", "TenTruyen", chap.TruyenID);
                return View(chap);
            }

            try
            {
                chap.NgayDang = DateTime.Now;
                data.Chaps.InsertOnSubmit(chap);

                var truyen = data.Truyens.SingleOrDefault(t => t.TruyenID == chap.TruyenID);
                if (truyen != null)
                {
                    truyen.SOCHAP = chap.SoChap;
                }

                data.SubmitChanges(); // để lấy ChapID

                if (AnhChapFiles != null)
                {
                    string folderPath = Server.MapPath("~/Content/ChapTruyen/");
                    if (!Directory.Exists(folderPath))
                        Directory.CreateDirectory(folderPath);

                    int soTrang = 1;

                    // IMPORTANT: AnhChapFiles is already in the order we set in client (DataTransfer)
                    foreach (var file in AnhChapFiles)
                    {
                        if (file == null || file.ContentLength <= 0) continue;

                        var anh = new AnhChap
                        {
                            ChapID = chap.ChapID,
                            SoTrang = soTrang,
                            LinkAnh = ""
                        };

                        data.AnhChaps.InsertOnSubmit(anh);
                        data.SubmitChanges(); // get anh.IDAnh

                        string fileName = anh.IDAnh + ".jpg";
                        string savePath = Path.Combine(folderPath, fileName);

                        // Optionally convert/resize here before save
                        file.SaveAs(savePath);

                        anh.LinkAnh = fileName;
                        data.SubmitChanges();

                        soTrang++;
                    }
                }

                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Lỗi khi lưu: " + ex.Message);
            }

            ViewBag.TruyenList = new SelectList(data.Truyens.OrderBy(t => t.TenTruyen), "TruyenID", "TenTruyen", chap.TruyenID);
            return View(chap);
        }


            public ActionResult Sua(int id)
            {
                var truyen = data.Truyens.FirstOrDefault(t => t.TruyenID == id);
                if (truyen == null) return HttpNotFound();

                ViewBag.TacGiaList = new SelectList(data.TacGias, "IDTacGia", "TenTacGia", truyen.IDTacGia);

                var tinhTrangData = new List<SelectListItem>
        {
            new SelectListItem { Value = "Đang tiến hành", Text = "Đang tiến hành" },
            new SelectListItem { Value = "Hoàn thành", Text = "Hoàn thành" } 
        };
                ViewBag.TinhTrangList = new SelectList(tinhTrangData, "Value", "Text", truyen.TinhTrang);
                List<TheLoai> dsTheLoai = data.TheLoais.OrderBy(tl => tl.TenTheLoai).ToList();
                ViewBag.TheLoaiList = dsTheLoai;
                ViewBag.SelectedTheLoaiIDs = data.Truyen_TheLoais
                                                 .Where(t => t.TruyenID == id)
                                                 .Select(t => t.TheLoaiID)
                                                 .ToList();

                return View(truyen);
            }

            [HttpPost]
            [ValidateAntiForgeryToken]
            public ActionResult Sua(Truyen truyen,
                                    HttpPostedFileBase AnhBiaFile,
                                    List<int> TheLoaiIDs)         
            {
                var old = data.Truyens.FirstOrDefault(t => t.TruyenID == truyen.TruyenID);
                if (old == null)
                {
                    ModelState.AddModelError("", "Không tìm thấy truyện để cập nhật.");
                    return View(truyen);
                }

                if (AnhBiaFile != null && AnhBiaFile.ContentLength > 0)
                {
                    if (AnhBiaFile.ContentType.StartsWith("image/"))
                    {
                        string fileName = Path.GetFileName(AnhBiaFile.FileName);
                        string path = Path.Combine(Server.MapPath("~/Content/AnhBia/"), fileName);
                        try
                        {
                            AnhBiaFile.SaveAs(path);
                            old.AnhBia = fileName;
                        }
                        catch (Exception ex)
                        {
                            ModelState.AddModelError("", "Lỗi lưu file: " + ex.Message);
                        }
                    }
                    else
                    {
                        ModelState.AddModelError("AnhBia", "Chỉ chấp nhận các tệp hình ảnh.");
                    }
                }

                if (ModelState.IsValid)
                {

                    old.TenTruyen = truyen.TenTruyen;
                    old.MoTa = truyen.MoTa;
                    old.SOCHAP = truyen.SOCHAP;
                    old.TinhTrang = truyen.TinhTrang;
                    old.IDTacGia = truyen.IDTacGia;
                    old.LuotXem = truyen.LuotXem;
                    old.NgayCapNhat = DateTime.Now;


                    var oldTheLoai = data.Truyen_TheLoais.Where(t => t.TruyenID == old.TruyenID);
                    data.Truyen_TheLoais.DeleteAllOnSubmit(oldTheLoai);

                    if (TheLoaiIDs != null && TheLoaiIDs.Any())
                    {
                        foreach (var tlID in TheLoaiIDs)
                        {
                            var truyenTheLoai = new Truyen_TheLoai
                            {
                                TruyenID = old.TruyenID,
                                TheLoaiID = tlID
                            };
                            data.Truyen_TheLoais.InsertOnSubmit(truyenTheLoai);
                        }
                    }

                    data.SubmitChanges();
                    return RedirectToAction("Index");
                }

                ViewBag.TacGiaList = new SelectList(data.TacGias, "IDTacGia", "TenTacGia", truyen.IDTacGia);
                var tinhTrangData = new List<SelectListItem>
        {
            new SelectListItem { Value = "Đang tiến hành", Text = "Đang tiến hành" },
            new SelectListItem { Value = "Hoàn thành", Text = "Hoàn thành" }
        };
                ViewBag.TinhTrangList = new SelectList(tinhTrangData, "Value", "Text", truyen.TinhTrang);
                ViewBag.TheLoaiList = data.TheLoais.OrderBy(tl => tl.TenTheLoai).ToList();

                ViewBag.SelectedTheLoaiIDs = TheLoaiIDs;

                return View(truyen);
            }

        [HttpPost]
        public ActionResult Xoa(int id)
        {
            System.Diagnostics.Debug.WriteLine("ID nhận được: " + id);

            var truyen = data.Truyens.FirstOrDefault(t => t.TruyenID == id);
            if (truyen == null) return RedirectToAction("Index");

            // 1. XÓA BÌNH LUẬN CỦA TRUYỆN & CHAP
            var binhLuanTruyen = data.BinhLuans.Where(b => b.IDTruyen == id);
            data.BinhLuans.DeleteAllOnSubmit(binhLuanTruyen);

            var chapIDs = data.Chaps.Where(c => c.TruyenID == id).Select(c => c.ChapID).ToList();
            if (chapIDs.Any())
            {
                var binhLuanChap = data.BinhLuans.Where(b => chapIDs.Contains((int)b.IDChap));
                data.BinhLuans.DeleteAllOnSubmit(binhLuanChap);
            }

            // 2. XÓA LỊCH SỬ ĐỌC
            var lichSuDoc = data.LichSuDocs.Where(l => l.TruyenID == id);
            data.LichSuDocs.DeleteAllOnSubmit(lichSuDoc);

            // 3. XÓA THEO DÕI
            var theoDoi = data.TruyenTheoDois.Where(t => t.TruyenID == id);
            data.TruyenTheoDois.DeleteAllOnSubmit(theoDoi);

            // 4. XÓA ĐÁNH GIÁ
            var danhGia = data.DANHGIAs.Where(d => d.TruyenID == id);
            data.DANHGIAs.DeleteAllOnSubmit(danhGia);

            // 5. XÓA LIÊN KẾT THỂ LOẠI
            var theLoai = data.Truyen_TheLoais.Where(tl => tl.TruyenID == id);
            data.Truyen_TheLoais.DeleteAllOnSubmit(theLoai);

            // 6. XÓA CHAP + ẢNH CHAP
            var chaps = data.Chaps.Where(c => c.TruyenID == id).ToList();

            foreach (var chap in chaps)
            {
                var anhList = data.AnhChaps.Where(a => a.ChapID == chap.ChapID);
                data.AnhChaps.DeleteAllOnSubmit(anhList);

                data.Chaps.DeleteOnSubmit(chap);
            }

            // 7. XÓA TRUYỆN
            data.Truyens.DeleteOnSubmit(truyen);

            // Lưu thay đổi
            try
            {
                data.SubmitChanges();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LỖI: " + ex.Message);
                return RedirectToAction("Index", "Home");
            }

            return RedirectToAction("Index");
        }


    }
}
