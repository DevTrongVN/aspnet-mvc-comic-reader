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
(N'Jujutsu Kaisen', 1, N'Một học sinh trung học tham gia vào một tổ chức Chú thuật sư bí mật...', N'bia_jujutsu_kaisen.jpg', 240, N'Đang tiến hành'),
(N'Solo Leveling', 2, N'Sau một lần "Thức tỉnh", một thợ săn yếu ớt nhận được sức mạnh vô hạn...', N'bia_solo_leveling.jpg', 200, N'Hoàn thành'),
(N'Mushoku Tensei', 3, N'Một người đàn ông thất nghiệp 34 tuổi tái sinh ở một thế giới phép thuật...', N'bia_mushoku_tensei.jpg', 90, N'Đang tiến hành'),
(N'One Piece', 4, N'Monkey D. Luffy và băng hải tặc Mũ Rơm đi tìm kho báu huyền thoại One Piece.', N'bia_one_piece.jpg', 1100, N'Đang tiến hành'),
(N'Spy x Family', 5, N'Một điệp viên, một sát thủ và một nhà ngoại cảm tạo nên một gia đình vỏ bọc.', N'bia_spy_x_family.jpg', 85, N'Đang tiến hành'),
(N'Kaguya-sama: Love Is War', 6, N'Cuộc chiến tỏ tình của hai thiên tài trong hội học sinh.', N'bia_kaguya_sama.jpg', 281, N'Hoàn thành'),
(N'Blue Lock', 7, N'Dự án đào tạo tiền đạo số một thế giới từ 300 học sinh trung học.', N'bia_blue_lock.jpg', 220, N'Đang tiến hành'),
(N'Chainsaw Man', 8, N'Một chàng trai trẻ lập khế ước với quỷ cưa máy để trả nợ.', N'bia_chainsaw_man.jpg', 150, N'Đang tiến hành'),
(N'BA', 12, N'Học sinh cầm súng go brr.', N'bia_ba.jpg', 130, N'Đang tiến hành'),
(N'CinderellaGray', 9, N'Câu chuyện về các thần tượng nỗ lực vươn tới đỉnh cao.', N'bia_cinderellagray.jpg', 120, N'Hoàn thành'),
(N'Kanan-sama', 10, N'Một nữ ác ma cố gắng trở nên dễ thương.', N'bia_kanansama.jpg', 115, N'Đang tiến hành'),
(N'RecordOfRagnarok', 11, N'Cuộc chiến giữa thần linh và nhân loại.', N'bia_recordofragnarok.jpg', 98, N'Đang tiến hành');
GO

INSERT INTO Truyen_TheLoai (TruyenID, TheLoaiID) VALUES
(1, 1), (1, 5), (1, 9), (1, 11),
(2, 1), (2, 2), (2, 5),
(3, 2), (3, 4), (3, 5), (3, 6),
(4, 1), (4, 2), (4, 3), (4, 9),
(5, 1), (5, 3), (5, 8),
(6, 3), (6, 7), (6, 8),
(7, 4), (7, 9), (7, 10),
(8, 1), (8, 4), (8, 9), (8, 11),
(9, 1), (9, 5),
(10, 4), (10, 8),
(11, 3), (11, 7), (11, 8),
(12, 1), (12, 4), (12, 5), (12, 11);
GO

INSERT INTO Chap (TieuDe, SoChap, TruyenID) VALUES
(N'Chương 1: Ryomen Sukuna', 1, 1),
(N'Chương 2: Hình phạt bí mật', 2, 1),
(N'Chương 3: Vì chính mình', 3, 1),
(N'Chương 1: Hầm ngục cấp E', 1, 2),
(N'Chương 2: Thử thách cuối cùng', 2, 2),
(N'Chương 3: Thức tỉnh', 3, 2),
(N'Chương 1: Gã đàn ông thất nghiệp', 1, 3),
(N'Chương 2: Vị gia sư đầu tiên', 2, 3),
(N'Chương 3: Ma thuật đầu đời', 3, 3),
(N'Chương 1: Bình minh của cuộc phiêu lưu', 1, 4),
(N'Chương 2: Gã thợ săn hải tặc Zoro', 2, 4),
(N'Chương 3: Morgan "Tay Rìu"', 3, 4),
(N'Chương 1: Nhiệm vụ "Strix"', 1, 5),
(N'Chương 2: Tìm một người vợ', 2, 5),
(N'Chương 3: Chuẩn bị cho buổi phỏng vấn', 3, 5),
(N'Chương 1: Tôi muốn cô ấy tỏ tình', 1, 6),
(N'Chương 2: Vé xem phim', 2, 6),
(N'Chương 3: Shirogane muốn trả lời', 3, 6),
(N'Chương 1: Giấc mơ', 1, 7),
(N'Chương 2: Con quái vật', 2, 7),
(N'Chương 3: Cái tôi của tiền đạo', 3, 7),
(N'Chương 1: Con chó và cưa máy', 1, 8),
(N'Chương 2: Nơi ở của Pochita', 2, 8),
(N'Chương 3: Đến Tokyo', 3, 8),
(N'Chương 1: Bắt Đầu', 1, 9),
(N'Chương 2: Tiếp Tục', 2, 9),
(N'Chương 3: Mới', 3, 9),
(N'Chương 1: Sân khấu đầu tiên', 1, 10),
(N'Chương 2: Ánh đèn', 2, 10),
(N'Chương 3: Lọ lem', 3, 10),
(N'Chương 1: Ác ma Kanan', 1, 11),
(N'Chương 2: Kế hoạch', 2, 11),
(N'Chương 3: Trái tim', 3, 11),
(N'Chương 1: Ragnarok', 1, 12),
(N'Chương 2: Lữ Bố vs Thor', 2, 12),
(N'Chương 3: Trận chiến bắt đầu', 3, 12);
GO

DELETE FROM AnhChap;
GO

DBCC CHECKIDENT (N'AnhChap', RESEED, 0);
GO

DELETE FROM AnhChap;
GO

DBCC CHECKIDENT (N'AnhChap', RESEED, 0);
GO

DECLARE @TruyenID INT = 1;
DECLARE @ChapOffset INT = 0;
DECLARE @ChapID INT;
DECLARE @Chap INT;
DECLARE @Trang INT;
DECLARE @Link NVARCHAR(500);
DECLARE @TenTruyen NVARCHAR(200);
DECLARE @TenTruyenKhongDau NVARCHAR(200);

DECLARE @TenTruyenTable TABLE (TruyenID INT, TenTruyenKhongDau NVARCHAR(200));
INSERT INTO @TenTruyenTable VALUES
(1,  N'JujutsuKaisen'),
(2,  N'SoloLeveling'),
(3,  N'MushokuTensei'),
(4,  N'OnePiece'),
(5,  N'SpyxFamily'),
(6,  N'KaguyaSamaLoveIsWar'),
(7,  N'BlueLock'),
(8,  N'ChainsawMan'),
(9,  N'BA'),
(10, N'CinderellaGray'),
(11, N'KananSama'),
(12, N'RecordOfRagnarok');

WHILE @TruyenID <= 12
BEGIN
    SELECT @TenTruyenKhongDau = TenTruyenKhongDau FROM @TenTruyenTable WHERE TruyenID = @TruyenID;
    SET @Chap = 1;

    WHILE @Chap <= 3
    BEGIN
        SET @ChapID = @ChapOffset + @Chap;
        SET @Trang = 1;

        WHILE @Trang <= 5
        BEGIN
            SET @Link = N'/ChapTruyen/' + @TenTruyenKhongDau + N'/' +
                        @TenTruyenKhongDau + N'_' + CAST(@Chap AS NVARCHAR(10)) + N'-' + CAST(@Trang AS NVARCHAR(10)) + N'.jpg';

            INSERT INTO AnhChap (ChapID, LinkAnh, SoTrang)
            VALUES (@ChapID, @Link, @Trang);

            SET @Trang = @Trang + 1;
        END

        SET @Chap = @Chap + 1;
    END

    SET @TruyenID = @TruyenID + 1;
    SET @ChapOffset = @ChapOffset + 3;
END
GO

SELECT * FROM AnhChap ORDER BY ChapID, SoTrang;

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
