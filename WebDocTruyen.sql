CREATE DATABASE WebDocTruyen;
GO
USE WebDocTruyen;
GO

/*
use master
drop database WebDocTruyen
*/

CREATE TABLE Taikhoan(
	IDNguoiDung INT IDENTITY(1,1) PRIMARY KEY,
	TenDangNhap NVARCHAR(100) UNIQUE NOT NULL,
    MatKhau NVARCHAR(100) NOT NULL,
	VaiTro INT NOT NULL,--1 Admin, 2Nguoi dung
	Avatar VARCHAR(100),
    HoTen NVARCHAR(100),
    Email NVARCHAR(150),
    NgayDangKy DATETIME DEFAULT GETDATE(),
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    TrangThai BIT DEFAULT 1  -- 1: hoạt động, 0: bị khóa
);
GO



CREATE TABLE TheLoai (
    TheLoaiID INT IDENTITY(1,1) PRIMARY KEY,
    TenTheLoai NVARCHAR(100) UNIQUE NOT NULL
);
GO

CREATE TABLE TacGia(
	IDTacGia INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 	
	TenTacGia NVARCHAR(100) NOT NULL,

);
GO

CREATE TABLE Truyen (
    TruyenID INT IDENTITY(1,1) PRIMARY KEY,
    TenTruyen NVARCHAR(200) NOT NULL,
    IDTacGia INT,
    MoTa NVARCHAR(MAX),
    AnhBia NVARCHAR(255),
    NgayCapNhat DATETIME DEFAULT GETDATE(),
	SOCHAP INT,
	LuotXem INT,
	TinhTrang NVARCHAR(100),
    FOREIGN KEY (IDTacGia) REFERENCES TacGia(IDTacGia)
);
GO

ALTER TABLE Truyen
ADD CONSTRAINT DF_Truyen_LuotXem  -- Đặt tên cho ràng buộc (Constraint)
DEFAULT 0 FOR LuotXem;           -- Đặt giá trị mặc định là 0 cho cột LuotXem
GO



CREATE TABLE DANHGIA(
IDDANHGIA INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
SOSAO INT,
NGAYDANHGIA DATE,
IDNguoidung INT,
TruyenID int,
FOREIGN KEY (IDNguoidung) REFERENCES Taikhoan(IDNguoidung),
FOREIGN KEY (TruyenID) REFERENCES Truyen(TruyenID)
);
GO



CREATE TABLE Chap (
    ChapID INT IDENTITY(1,1) PRIMARY KEY,
    TieuDe NVARCHAR(200),
	SoChap INT NOT NULL,
    NgayDang DATETIME DEFAULT GETDATE(),
    TruyenID INT NOT NULL,
    FOREIGN KEY (TruyenID) REFERENCES Truyen(TruyenID)
);
GO

CREATE TABLE AnhChap(
	IDAnh INT IDENTITY(1,1) PRIMARY KEY,
	ChapID INT,
	FOREIGN KEY (ChapID) REFERENCES Chap(ChapID),
	LinkAnh VarChar(100),
	SoTrang INT,
	UNIQUE (ChapID,SoTrang)
);
GO

CREATE TABLE Truyen_TheLoai (
    TruyenID INT NOT NULL,
    TheLoaiID INT NOT NULL,
    PRIMARY KEY (TruyenID, TheLoaiID),
    FOREIGN KEY (TruyenID) REFERENCES Truyen(TruyenID),
    FOREIGN KEY (TheLoaiID) REFERENCES TheLoai(TheLoaiID)
);
GO

CREATE TABLE BinhLuan (
    BinhLuanID INT IDENTITY(1,1) PRIMARY KEY,
    NoiDung NVARCHAR(MAX) NOT NULL,
    NgayDang DATETIME DEFAULT GETDATE(),
    IDNguoiDung INT,
	IDChap INT,
	IDTruyen INT,
	FOREIGN KEY (IDTruyen) REFERENCES Truyen(TruyenID),
    FOREIGN KEY (IDChap) REFERENCES Chap(ChapID),
    FOREIGN KEY (IDNguoiDung) REFERENCES Taikhoan(IDNguoiDung)
);


CREATE TABLE TruyenTheoDoi ( 
    IDNguoiDung INT NOT NULL,
    TruyenID INT NOT NULL,
    NgayTheoDoi DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (IDNguoiDung, TruyenID),
    FOREIGN KEY (IDNguoiDung) REFERENCES Taikhoan(IDNguoiDung),
    FOREIGN KEY (TruyenID) REFERENCES Truyen(TruyenID)
);
GO

-- BẢNG MỚI: LỊCH SỬ ĐỌC (Lưu chương cuối cùng người dùng đã đọc)
CREATE TABLE LichSuDoc (
    IDNguoiDung INT NOT NULL,
    TruyenID INT NOT NULL,
	ChapID INT NOT NULL, -- Chương cuối cùng người dùng đã đọc
    NgayDocCuoi DATETIME DEFAULT GETDATE(), -- Thời gian đọc gần nhất
    PRIMARY KEY (IDNguoiDung, TruyenID),
    FOREIGN KEY (IDNguoiDung) REFERENCES Taikhoan(IDNguoiDung),
    FOREIGN KEY (TruyenID) REFERENCES Truyen(TruyenID),
	FOREIGN KEY (ChapID) REFERENCES Chap(ChapID)
);
GO



-- VaiTro: 1 = Admin, 2 = NguoiDung
INSERT INTO Taikhoan (TenDangNhap, MatKhau, VaiTro, HoTen, Email, GioiTinh, NgaySinh) VALUES
('admin', '123', 1, N'Nguyễn Văn A', 'admin@doctruyen.vn', N'Nam', '1990-01-01'),
('user01', '123', 2, N'Trần Thị B', 'user1@email.com', N'Nữ', '1995-05-15'),
('user02', '123', 2, N'Lê Văn C', 'user2@email.com', N'Nam', '2000-10-20');


INSERT INTO TheLoai (TenTheLoai) VALUES
(N'Hành động'),
(N'Phiêu lưu'),
(N'Comedy'),
(N'Drama'),
(N'Fantasy'),
(N'Isekai'),
(N'Romance'),
(N'School Life'),
(N'Shounen'),
(N'Sports'),
(N'Supernatural'),
(N'Light Novel');
GO

INSERT INTO TacGia (TenTacGia) VALUES
(N'Akutami Gege'),
(N'Chugong'),
(N'Rifujin na Magonote'),
(N'Eiichiro Oda'),
(N'Tatsuya Endo'),
(N'Aka Akasaka'),
(N'Kaneshiro Muneyuki'),
(N'Tatsuki Fujimoto'),
(N'Banei Tatsuya'),
(N'nonco'),
(N'Shinya Umemura'),
(N'Đang cập nhật');
GO

INSERT INTO Truyen (TenTruyen, IDTacGia, MoTa, AnhBia, SOCHAP, TinhTrang) VALUES
(N'BA', 12, N'Học sinh cầm súng go brr.', N'1.jpg', 3, N'Đang tiến hành'),
(N'Blue Lock', 7, N'Dự án đào tạo tiền đạo số một thế giới từ 300 học sinh trung học.', N'2.jpg', 3, N'Đang tiến hành'),
(N'Chainsaw Man', 8, N'Một chàng trai trẻ lập khế ước với quỷ cưa máy để trả nợ.', N'3.jpg', 3, N'Đang tiến hành'),
(N'CinderellaGray', 9, N'Câu chuyện về các thần tượng nỗ lực vươn tới đỉnh cao.', N'4.jpg', 3, N'Hoàn thành'),
(N'Jujutsu Kaisen', 1, N'Một học sinh trung học tham gia vào một tổ chức Chú thuật sư bí mật...', N'5.jpg', 3, N'Đang tiến hành'),
(N'Kaguya-sama: Love Is War', 6, N'Cuộc chiến tỏ tình của hai thiên tài trong hội học sinh.', N'6.jpg', 3, N'Hoàn thành'),
(N'Kanan-sama', 10, N'Một nữ ác ma cố gắng trở nên dễ thương.', N'7.jpg', 3, N'Đang tiến hành'),
(N'Mushoku Tensei', 3, N'Một người đàn ông thất nghiệp 34 tuổi tái sinh ở một thế giới phép thuật...', N'8.jpg', 3, N'Đang tiến hành'),
(N'One Piece', 4, N'Monkey D. Luffy và băng hải tặc Mũ Rơm đi tìm kho báu huyền thoại One Piece.', N'9.jpg', 3, N'Đang tiến hành'),
(N'Solo Leveling', 2, N'Sau một lần "Thức tỉnh", một thợ săn yếu ớt nhận được sức mạnh vô hạn...', N'10.jpg', 3, N'Hoàn thành'),
(N'RecordOfRagnarok', 11, N'Cuộc chiến giữa thần linh và nhân loại.', N'11.jpg', 3, N'Đang tiến hành'),
(N'Spy x Family', 5, N'Một điệp viên, một sát thủ và một nhà ngoại cảm tạo nên một gia đình vỏ bọc.', N'12.jpg', 3, N'Đang tiến hành');
GO

INSERT INTO Truyen_TheLoai (TruyenID, TheLoaiID) VALUES
(5, 1), (5, 5), (5, 9), (5, 11),
(10, 1), (10, 2), (10, 5),
(8, 2), (8, 4), (8, 5), (8, 6),
(9, 1), (9, 2), (9, 3), (9, 9),
(12, 1), (12, 3), (12, 8),
(6, 3), (6, 7), (6, 8),
(2, 4), (2, 9), (2, 10),
(3, 1), (3, 4), (3, 9), (3, 11),
(1, 1), (1, 5),
(4, 4), (4, 8),
(7, 3), (7, 7), (7, 8),
(11, 1), (11, 4), (11, 5), (11, 11);
GO
INSERT INTO Chap (TieuDe, SoChap, TruyenID) VALUES
(N'Chương 1: Bắt Đầu', 1, 1),
(N'Chương 2: Tiếp Tục', 2, 1),
(N'Chương 3: Mới', 3, 1),

(N'Chương 1: Giấc mơ', 1, 2),
(N'Chương 2: Con quái vật', 2, 2),
(N'Chương 3: Cái tôi của tiền đạo', 3, 2),

(N'Chương 1: Con chó và cưa máy', 1, 3),
(N'Chương 2: Nơi ở của Pochita', 2, 3),
(N'Chương 3: Đến Tokyo', 3, 3),

(N'Chương 1: Sân khấu đầu tiên', 1, 4),
(N'Chương 2: Ánh đèn', 2, 4),
(N'Chương 3: Lọ lem', 3, 4),

(N'Chương 1: Ryomen Sukuna', 1, 5),
(N'Chương 2: Hình phạt bí mật', 2, 5),
(N'Chương 3: Vì chính mình', 3, 5),

(N'Chương 1: Tôi muốn cô ấy tỏ tình', 1, 6),
(N'Chương 2: Vé xem phim', 2, 6),
(N'Chương 3: Shirogane muốn trả lời', 3, 6),

(N'Chương 1: Ác ma Kanan', 1, 7),
(N'Chương 2: Kế hoạch', 2, 7),
(N'Chương 3: Trái tim', 3, 7),

(N'Chương 1: Gã đàn ông thất nghiệp', 1, 8),
(N'Chương 2: Vị gia sư đầu tiên', 2, 8),
(N'Chương 3: Ma thuật đầu đời', 3, 8),

(N'Chương 1: Bình minh của cuộc phiêu lưu', 1, 9),
(N'Chương 2: Gã thợ săn hải tặc Zoro', 2, 9),
(N'Chương 3: Morgan "Tay Rìu"', 3, 9),

(N'Chương 1: Hầm ngục cấp E', 1, 10),
(N'Chương 2: Thử thách cuối cùng', 2, 10),
(N'Chương 3: Thức tỉnh', 3, 10),

(N'Chương 1: Ragnarok', 1, 11),
(N'Chương 2: Lữ Bố vs Thor', 2, 11),
(N'Chương 3: Trận chiến bắt đầu', 3, 11),

(N'Chương 1: Nhiệm vụ "Strix"', 1, 12),
(N'Chương 2: Tìm một người vợ', 2, 12),
(N'Chương 3: Chuẩn bị cho buổi phỏng vấn', 3, 12);
GO

INSERT INTO AnhChap (ChapID, LinkAnh, SoTrang) VALUES
(1, '1.jpg', 1),
(1, '2.jpg', 2),
(1, '3.jpg', 3),
(1, '4.jpg', 4),
(1, '5.jpg', 5),
(1, '6.jpg', 6),
(1, '7.jpg', 7),
(2, '8.jpg', 1),
(2, '9.jpg', 2),
(2, '10.jpg', 3),
(2, '11.jpg', 4),
(2, '12.jpg', 5),
(2, '13.jpg', 6),
(3, '14.jpg', 1),
(3, '15.jpg', 2),
(3, '16.jpg', 3),
(3, '17.jpg', 4),
(3, '18.jpg', 5),
(3, '19.jpg', 6),
(3, '20.jpg', 7),
(4, '21.jpg', 1),
(4, '22.jpg', 2),
(4, '23.jpg', 3),
(4, '24.jpg', 4),
(4, '25.jpg', 5),
(5, '26.jpg', 1),
(5, '27.jpg', 2),
(5, '28.jpg', 3),
(5, '29.jpg', 4),
(5, '30.jpg', 5),
(6, '31.jpg', 1),
(6, '32.jpg', 2),
(6, '33.jpg', 3),
(6, '34.jpg', 4),
(6, '35.jpg', 5),
(7, '36.jpg', 1),
(7, '37.jpg', 2),
(7, '38.jpg', 3),
(7, '39.jpg', 4),
(7, '40.jpg', 5),
(8, '41.jpg', 1),
(8, '42.jpg', 2),
(8, '43.jpg', 3),
(8, '44.jpg', 4),
(8, '45.jpg', 5),
(9, '46.jpg', 1),
(9, '47.jpg', 2),
(9, '48.jpg', 3),
(9, '49.jpg', 4),
(9, '50.jpg', 5),
(10, '51.jpg', 1),
(10, '52.jpg', 2),
(10, '53.jpg', 3),
(10, '54.jpg', 4),
(10, '55.jpg', 5),
(10, '56.jpg', 6),
(11, '57.jpg', 1),
(11, '58.jpg', 2),
(11, '59.jpg', 3),
(11, '60.jpg', 4),
(11, '61.jpg', 5),
(12, '62.jpg', 1),
(12, '63.jpg', 2),
(12, '64.jpg', 3),
(12, '65.jpg', 4),
(12, '66.jpg', 5),
(13, '67.jpg', 1),
(13, '68.jpg', 2),
(13, '69.jpg', 3),
(13, '70.jpg', 4),
(13, '71.jpg', 5),
(14, '72.jpg', 1),
(14, '73.jpg', 2),
(14, '74.jpg', 3),
(14, '75.jpg', 4),
(14, '76.jpg', 5),
(15, '77.jpg', 1),
(15, '78.jpg', 2),
(15, '79.jpg', 3),
(15, '80.jpg', 4),
(15, '81.jpg', 5),
(16, '82.jpg', 1),
(16, '83.jpg', 2),
(16, '84.jpg', 3),
(16, '85.jpg', 4),
(16, '86.jpg', 5),
(17, '87.jpg', 1),
(17, '88.jpg', 2),
(17, '89.jpg', 3),
(17, '90.jpg', 4),
(17, '91.jpg', 5),
(18, '92.jpg', 1),
(18, '93.jpg', 2),
(18, '94.jpg', 3),
(18, '95.jpg', 4),
(18, '96.jpg', 5),
(19, '97.jpg', 1),
(19, '98.jpg', 2),
(19, '99.jpg', 3),
(19, '100.jpg', 4),
(19, '101.jpg', 5),
(19, '102.jpg', 6),
(20, '103.jpg', 1),
(20, '104.jpg', 2),
(20, '105.jpg', 3),
(20, '106.jpg', 4),
(20, '107.jpg', 5),
(20, '108.jpg', 6),
(21, '109.jpg', 1),
(21, '110.jpg', 2),
(21, '111.jpg', 3),
(21, '112.jpg', 4),
(21, '113.jpg', 5),
(22, '114.jpg', 1),
(22, '115.jpg', 2),
(22, '116.jpg', 3),
(22, '117.jpg', 4),
(22, '118.jpg', 5),
(23, '119.jpg', 1),
(23, '120.jpg', 2),
(23, '121.jpg', 3),
(23, '122.jpg', 4),
(23, '123.jpg', 5),
(24, '124.jpg', 1),
(24, '125.jpg', 2),
(24, '126.jpg', 3),
(24, '127.jpg', 4),
(24, '128.jpg', 5),
(25, '129.jpg', 1),
(25, '130.jpg', 2),
(25, '131.jpg', 3),
(25, '132.jpg', 4),
(25, '133.jpg', 5),
(26, '134.jpg', 1),
(26, '135.jpg', 2),
(26, '136.jpg', 3),
(26, '137.jpg', 4),
(26, '138.jpg', 5),
(27, '139.jpg', 1),
(27, '140.jpg', 2),
(27, '141.jpg', 3),
(27, '142.jpg', 4),
(27, '143.jpg', 5),
(28, '144.jpg', 1),
(28, '145.jpg', 2),
(28, '146.jpg', 3),
(28, '147.jpg', 4),
(28, '148.jpg', 5),
(29, '149.jpg', 1),
(29, '150.jpg', 2),
(29, '151.jpg', 3),
(29, '152.jpg', 4),
(29, '153.jpg', 5),
(30, '154.jpg', 1),
(30, '155.jpg', 2),
(30, '156.jpg', 3),
(30, '157.jpg', 4),
(30, '158.jpg', 5),
(31, '159.jpg', 1),
(31, '160.jpg', 2),
(31, '161.jpg', 3),
(31, '162.jpg', 4),
(31, '163.jpg', 5),
(31, '164.jpg', 6),
(32, '165.jpg', 1),
(32, '166.jpg', 2),
(32, '167.jpg', 3),
(32, '168.jpg', 4),
(32, '169.jpg', 5),
(32, '170.jpg', 6),
(33, '171.jpg', 1),
(33, '172.jpg', 2),
(33, '173.jpg', 3),
(33, '174.jpg', 4),
(33, '175.jpg', 5),
(33, '176.jpg', 6),
(34, '177.jpg', 1),
(34, '178.jpg', 2),
(34, '179.jpg', 3),
(34, '180.jpg', 4),
(34, '181.jpg', 5),
(35, '182.jpg', 1),
(35, '183.jpg', 2),
(35, '184.jpg', 3),
(35, '185.jpg', 4),
(35, '186.jpg', 5),
(36, '187.jpg', 1),
(36, '188.jpg', 2),
(36, '189.jpg', 3),
(36, '190.jpg', 4),
(36, '191.jpg', 5);

Go
SELECT * FROM AnhChap ORDER BY ChapID, SoTrang;
Go
INSERT INTO TruyenTheoDoi (IDNguoiDung, TruyenID, NgayTheoDoi) VALUES
(2, 1, GETDATE()),
(3, 2, GETDATE()),
(2, 4, GETDATE());
GO

INSERT INTO DANHGIA (SOSAO, NGAYDANHGIA, IDNguoidung, TruyenID) VALUES
(5, '2025-10-20', 2, 1),
(4, '2025-10-21', 3, 2);
GO

INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap) VALUES
(N'Truyện hay và hấp dẫn quá!', 2, 1),
(N'Hóng chương mới!', 3, 4);
GO

INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Cốt truyện hấp dẫn ngay từ chương đầu!', 2, 1, 1),
(N'Bình luận để lấy tương tác hehe. Truyện vẽ đẹp ghê!', 3, 1, 1),
(N'Nhân vật chính mạnh mẽ, đúng gu của tôi.', 2, 2, 1),
(N'Mong chờ các chương sau có thêm pha hành động kịch tính!', 3, 3, 1),
(N'Tóm tắt truyện có vẻ hơi ít, nhưng ảnh chap chất lượng.', 1, 1, 1);

-- Truyện ID 2 (Blue Lock) - ChapID 4
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Truyện về bóng đá này quá cháy, đặc biệt là triết lý ích kỷ.', 3, 4, 2),
(N'Nhân vật Isagi có sự phát triển rõ rệt, rất đáng xem.', 2, 4, 2),
(N'Không ngờ truyện thể thao lại có drama căng thẳng thế này.', 1, 5, 2),
(N'Art của tác giả Blue Lock đỉnh cao thật sự!', 3, 6, 2),
(N'Tuyệt vời! Tuyệt vời! Tôi đã xem anime và giờ đọc manga.', 2, 4, 2);

-- Truyện ID 3 (Chainsaw Man) - ChapID 7
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Denji và Pochita là bộ đôi huyền thoại, quá ngầu!', 2, 7, 3),
(N'Nội dung ngày càng điên rồ và cuốn hút.', 1, 8, 3),
(N'Tác giả Fujimoto đúng là thiên tài tạo ra những câu chuyện khó lường.', 3, 9, 3),
(N'Hóng Power trở lại!', 2, 7, 3),
(N'Màu sắc của chap này hơi tối, hy vọng các chap sau sáng hơn.', 1, 7, 3);

-- Truyện ID 4 (CinderellaGray) - ChapID 10
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Cảm động quá! Cố lên CinderellaGray!', 1, 10, 4),
(N'Manga này thật sự truyền cảm hứng về sự nỗ lực.', 3, 10, 4),
(N'Tôi khóc ở cảnh Gray giành chiến thắng đầu tiên.', 2, 11, 4),
(N'Một câu chuyện hay và ý nghĩa, hình ảnh cũng đẹp.', 1, 12, 4),
(N'Đã theo dõi từ những chương đầu, giờ hoàn thành rồi!', 3, 10, 4);

-- Truyện ID 5 (Jujutsu Kaisen) - ChapID 13
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Gojo Satoru là số 1 không cần bàn cãi!', 3, 13, 5),
(N'Kết cục của sự kiện Shibuya quá bi thảm. Tác giả ác thật.', 2, 14, 5),
(N'Mong chờ diễn biến của Yuji trong trận chiến cuối.', 1, 15, 5),
(N'Kết giới chú thuật của Megumi đỉnh cao!', 3, 13, 5),
(N'Hay quá, hay quá! Tôi đọc liền một mạch.', 2, 15, 5);

-- Truyện ID 6 (Kaguya-sama: Love Is War) - ChapID 16
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Cuộc chiến tình yêu này hài hước không đỡ nổi!', 2, 16, 6),
(N'Ai sẽ tỏ tình trước? Tôi cược là Kaguya!', 1, 16, 6),
(N'Chưa bao giờ thấy một câu chuyện lãng mạn mà lại chiến lược đến thế.', 3, 17, 6),
(N'Chika Fujiwara là nhân vật tạo tiếng cười nhiều nhất.', 2, 18, 6),
(N'Tuyệt phẩm rom-com đã hoàn thành, hơi tiếc nhưng rất viên mãn.', 1, 16, 6);

-- Truyện ID 7 (Kanan-sama) - ChapID 19
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Ác ma Kanan dễ thương thế này ai mà chịu nổi!', 1, 19, 7),
(N'Truyện ngọt ngào, nhẹ nhàng, đọc giải trí rất tốt.', 3, 20, 7),
(N'Tôi thích phong cách vẽ của truyện này.', 2, 19, 7),
(N'Hóng cảnh Kanan-sama thực hiện kế hoạch dễ thương tiếp theo!', 1, 19, 7),
(N'Đọc vào buổi tối rất thư giãn.', 3, 21, 7);

-- Truyện ID 8 (Mushoku Tensei) - ChapID 22
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Isekai nhưng có chiều sâu về tâm lý nhân vật chính Rudeus.', 3, 22, 8),
(N'Manga này chuyển thể rất tốt từ light novel.', 2, 23, 8),
(N'Tôi yêu Roxy và Eris!', 1, 24, 8),
(N'Cốt truyện có nhiều tình tiết bất ngờ và cảm xúc.', 3, 22, 8),
(N'Gã thất nghiệp đã tìm thấy ý nghĩa cuộc sống mới.', 2, 25, 8);

-- Truyện ID 9 (One Piece) - ChapID 25
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Vẫn là huyền thoại của mọi thời đại, mãi đỉnh!', 2, 25, 9),
(N'Cảnh Zoro gặp Morgan "Tay Rìu" kinh điển quá!', 1, 26, 9),
(N'Tôi mong Luffy sớm trở thành Vua Hải Tặc!', 3, 27, 9),
(N'Cảm ơn Oda-sensei vì tuổi thơ tuyệt vời.', 2, 25, 9),
(N'Chapter mới nhất ở Wano hoành tráng lắm.', 1, 25, 9);

-- Truyện ID 10 (Solo Leveling) - ChapID 28
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Thức tỉnh xong Sung Jin Woo quá ngầu. Lên cấp điên cuồng!', 3, 28, 10),
(N'Manga Hàn Quốc hay nhất tôi từng đọc.', 2, 29, 10),
(N'Cảnh hầm ngục kép rợn người thật.', 1, 30, 10),
(N'Tôi thích đội quân bóng tối của anh ấy.', 3, 28, 10),
(N'Hào quang của Hunter Sung Jin Woo không ai sánh kịp.', 2, 30, 10);

-- Truyện ID 11 (RecordOfRagnarok) - ChapID 31
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Trận đấu giữa Lữ Bố và Thor quá mãn nhãn, hình ảnh cực kỳ chi tiết.', 2, 31, 11),
(N'Ai sẽ là người đại diện tiếp theo của nhân loại?', 1, 32, 11),
(N'Zeus vs Adam là trận đấu huyền thoại!', 3, 33, 11),
(N'Cốt truyện chiến đấu đơn giản nhưng cực kỳ cuốn hút.', 2, 31, 11),
(N'Tôi luôn cổ vũ cho phe nhân loại, mặc dù khó khăn.', 1, 31, 11);

-- Truyện ID 12 (Spy x Family) - ChapID 34
INSERT INTO BinhLuan (NoiDung, IDNguoiDung, IDChap, IDTruyen) VALUES
(N'Anya Forger là thiên thần! Waku Waku!', 1, 34, 12),
(N'Gia đình giả dối mà chân thật hơn cả gia đình thật.', 3, 35, 12),
(N'Yor quá ngây thơ, Loid quá nghiêm túc, Anya quá đáng yêu.', 2, 36, 12),
(N'Truyện này không có gì để chê, vừa hài vừa ấm áp.', 1, 34, 12),
(N'Chuẩn bị cho buổi phỏng vấn mà căng thẳng như điệp vụ quốc gia!', 3, 34, 12);
GO




	SELECT * FROM Taikhoan;
	SELECT * FROM TheLoai;
	SELECT * FROM TacGia;
	SELECT * FROM Truyen;
	SELECT * FROM Chap;
	SELECT * FROM AnhChap;
	SELECT * FROM Truyen_TheLoai;
	SELECT * FROM TruyenTheoDoi;
	SELECT * FROM DANHGIA;
	SELECT * FROM BinhLuan;
