--lệnh if exists để xóa database nếu đã tồn tại trước đó 
USE master;
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'THCSDL_N4')
BEGIN
    ALTER DATABASE THCSDL_N4 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE THCSDL_N4;
END;
create database THCSDL_N4
go
use THCSDL_N4
go
create table NHACUNGCAP
(
	MaCongTy char(10) primary key,
	TenCongTy nvarchar(50) not null,
	TenGiaoDich nvarchar(50) not null,
	DiaChi nvarchar(50) ,
	DienThoai char(10) CHECK ((LEN(DIENTHOAI) = 10 OR LEN(DIENTHOAI)=11) AND DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	Fax char(10) ,
	Email varchar(30) CHECK (EMAIL LIKE '[a-z]%@%') UNIQUE,
)
create table LOAIHANG 
(
	MaLoaiHang char(10) primary key,
	TenLoaiHang nvarchar (30),
)
create table MATHANG
(
	MaHang char(10) primary key,
	Tenhang nvarchar(30) not null,
	MaCongTyNo char(10) 
    foreign key references NHACUNGCAP(MaCongTy)
		on 
			delete cascade 
		on 
			update cascade,
	MaLoaiHangNo char(10)
		foreign key references LOAIHANG(MaLoaiHang)
		on 
			delete cascade 
		on 
			update cascade,
	SoLuong int check(SoLuong>=0),
	DonViTinh varchar(20) not null,
	GiaHang money not null,
)
create table KHACHHANG
(
	MaKhachHang char(10) primary key,
	TenCongTy nvarchar(50) ,
	TenGiaoDich nvarchar(50) ,
	DiaChi nvarchar(100) ,
	Email varchar(50) UNIQUE CHECK (EMAIL LIKE '[a-z]%@%'),
	DienThoai char(10) UNIQUE CHECK ((LEN(DIENTHOAI) = 10 OR LEN(DIENTHOAI)=11) AND (DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')),
	Fax char (11) null,
)
create table NHANVIEN
(
	MaNhanVien char(10) primary key,
	HO nvarchar(50) not null,
	TEN nvarchar(50) not null,
	NgaySinh date CHECK (NGAYSINH < GETDATE()),
	NgayLamViec date ,
	DiaChi nvarchar(100) ,
	DienThoai char(10) CHECK ((LEN(DIENTHOAI) = 10 OR LEN(DIENTHOAI)=11) AND (DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')),
	LuongCB money CHECK (LUONGCB >= 0),
	PhuCap money default 0 CHECK (PHUCAP >= 0) 
);
create table DONDATHANG
(
	SoHoaDon char(10) primary key,
	MaKhachHangNo char(10) 
		foreign key references KHACHHANG(MaKhachHang)
		on 
			delete cascade 
		on 
			update cascade,
	MaNhanVienNo char(10) not null 
		foreign key references NHANVIEN(MaNhanVien)
		on 
			delete cascade 
		on 
			update cascade,
	NgayDatHang date ,
	NgayGiaoHang date ,
	NgayChuyenHang date,
	NoiGiaoHang nvarchar(100) not null,
)
create table CHITIETDATHANG
(
	SoHoaDonNo char(10) not null 
		foreign key references DONDATHANG(SoHoaDon)
		on 
			delete cascade 
		on 
			update cascade,
	MaHangNo char(10) not null 
		foreign key references MATHANG(MaHang)
		on 
			delete cascade 
		on 
			update cascade,
	primary key(SoHoaDonNo,MaHangNo),
	GiaBan money CHECK(GIABAN >= 0),
	SoLuong int CHECK(SOLUONG >= 0),
	MucGiamGia decimal(7,2) ,
)
create table QUOCGIA
(
    MaQG char(5) PRIMARY KEY,
    TenQuocGia nvarchar(50),
)
create table TINHTP
(
    MaTTP char(5) PRIMARY KEY,
    MaQGNO char(5),
    TenTinhTP nvarchar(50),
    CONSTRAINT FK_TINHTP FOREIGN KEY(MaQGNO) REFERENCES QUOCGIA(MaQG)
)
create table QUANHUYEN
(
    MaQH char(5) PRIMARY KEY,
    MaTTPNO char(5),
    TenQuanHuyen nvarchar(50),
CONSTRAINT FK_QUANHUYEN FOREIGN KEY(MaTTPNO) REFERENCES TINHTP(MaTTP)
)
create table PHUONGXA
(
    MaPX char(5) PRIMARY KEY,
    MaQHNO char(5),
    TenPX nvarchar(50),
    CONSTRAINT FK_PHUONGXA FOREIGN KEY(MaQHNO) REFERENCES QUANHUYEN(MaQH)
)

-------------------Chỉnh sửa Tuần 6-----------------
/*1. Thiết lập  mối quan hệ giữa các bảng.
2.Bổ sung ràng buộc thiết lập giá trị mặc định bằng 1 cho cột SoLuong  và bằng 0 cho cột MucGiamGia trong bảng CHITIETDATHANG
3.Bổ sung cho bảng DONDATHANG ràng buộc kiểm tra ngày giao hàng và ngày chuyển hàng phải sau hoặc bằng với ngày đặt hàng.
4.Bổ sung ràng buộc cho bảng NHANVIEN để đảm bảo rằng một nhân viên chỉ có thể làm việc trong công ty khi đủ 18 tuổi và không quá 60 tuổi*/

--2. Bổ sung ràng buộc thiết lập giá trị mặc định bằng 1 cho cột SoLuong  và bằng 0 cho cột MucGiamGia trong bảng CHITIETDATHANG
alter table CHITIETDATHANG
	add
		constraint DF_CHITIETDONHANG_SoLuong 
			default 1 for SoLuong,
		constraint DF_CHITIETDATHANG_MucGiamGia
			default 0.0 for MucGiamGia;
--3. Bổ sung cho bảng DONDATHANG ràng buộc kiểm tra ngày giao hàng và ngày chuyển hàng phải sau hoặc bằng với ngày đặt hàng.
alter table DONDATHANG
	add 
		constraint CK_DONDATHANG_NgayGiaoHang 
			check(NgayGiaoHang >= NgayDatHang),
		constraint CK_DONDATHANG_NgayChuyenHang
			check(NgayChuyenHang >= NgayDatHang);
--4. Bổ sung ràng buộc cho bảng NHANVIEN để đảm bảo rằng một nhân viên chỉ có thể làm việc trong công ty khi đủ 18 tuổi và không quá 60 tuổi
alter table NHANVIEN
	add
		constraint CK_NHANVIEN_NgaySinh
			check(datediff(year,NgaySinh,getdate())>=18 and datediff(year,NgaySinh,getdate())<=60);
GO

-- 1. Xóa các trường DiaChi và NoiGiaoHang
ALTER TABLE NHACUNGCAP DROP COLUMN DiaChi;
ALTER TABLE KHACHHANG DROP COLUMN DiaChi;
ALTER TABLE NHANVIEN DROP COLUMN DiaChi;
ALTER TABLE DONDATHANG DROP COLUMN NoiGiaoHang;

-- 2. Thêm các trường mới SoNhaTenDuong và MaPXNo vào các bảng liên quan
GO
-- Bảng NHACUNGCAP
ALTER TABLE NHACUNGCAP
    ADD SoNhaTenDuong NVARCHAR(50),
        MaPXNo CHAR(5),
    CONSTRAINT FK_NHACUNGCAP_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX);
GO
-- Bảng KHACHHANG
ALTER TABLE KHACHHANG
    ADD SoNhaTenDuong NVARCHAR(50),
        MaPXNo CHAR(5),
    CONSTRAINT FK_KHACHHANG_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX);
GO
--Bang DONDATHANG
ALTER TABLE DONDATHANG
    ADD SoNhaTenDuong NVARCHAR(50),
        MaPXNo CHAR(5),
    CONSTRAINT FK_DONDATHANG_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX);
GO
--Bang NHANVIEN
ALTER TABLE NHANVIEN
    ADD SoNhaTenDuong NVARCHAR(50),
        MaPXNo CHAR(5),
    CONSTRAINT FK_NHANVIEN_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX);
GO

-- Dữ liệu cho bảng QUOCGIA
-- Dữ liệu cho bảng QUOCGIA
INSERT INTO QUOCGIA (MaQG, TenQuocGia) VALUES
('QG001', N'Việt Nam'),
('QG002', N'Mỹ'),
('QG003', N'Nhật Bản'),
('QG004', N'Trung Quốc'),
('QG005', N'Hàn Quốc'),
('QG006', N'Đức'),
('QG007', N'Pháp'),
('QG008', N'Anh'),
('QG009', N'Úc'),
('QG010', N'Canada');


--Dữ liệu cho bảng TINHTP
INSERT INTO TINHTP (MaTTP, MaQGNO, TenTinhTP) VALUES
('TP001', 'QG001', N'Hà Nội'),
('TP002', 'QG001', N'TP.HCM'),
('TP003', 'QG001', N'Đà Nẵng'),
('TP004', 'QG001', N'Hải Phòng'),
('TP005', 'QG001', N'Nha Trang'),
('TP006', 'QG002', N'New York'),
('TP007', 'QG002', N'Los Angeles'),
('TP008', 'QG003', N'Tokyo'),
('TP009', 'QG003', N'Osaka'),
('TP010', 'QG004 ',N'Bắc Kinh');

-- Dữ liệu cho bảng QUANHUYEN

INSERT INTO QUANHUYEN (MaQH, MaTTPNO, TenQuanHuyen) VALUES
('QH001', 'TP001', N'Quận Hoàn Kiếm'),
('QH002', 'TP001', N'Quận Ba Đình'),
('QH003', 'TP002', N'Quận 1'),
('QH004', 'TP002', N'Quận 3'),
('QH005', 'TP003', N'Quận Hải Châu'),
('QH006', 'TP004', N'Quận Hồng Bàng'),
('QH007', 'TP005', N'Quận Nha Trang'),
('QH008', 'TP006', N'Quận Manhattan'),
('QH009', 'TP007', N'Quận Westminster'),
('QH010', 'TP008', N'Quận Shibuya');

--Dữ liệu cho bảng PHUONGXA
INSERT INTO PHUONGXA (MaPX, MaQHNO, TenPX) VALUES
('PX001', 'QH001', N'Phường Hàng Bài'),
('PX002', 'QH001', N'Phường Tràng Tiền'),
('PX003', 'QH002', N'Phường Phúc Xá'),
('PX004', 'QH002', N'Phường Cống Vị'),
('PX005', 'QH003', N'Phường Bến Nghé'),
('PX006', 'QH003', N'Phường Đa Kao'),
('PX007', 'QH004', N'Phường Hạ Lý'),
('PX008', 'QH005', N'Phường Lộc Thọ'),
('PX009', 'QH006', N'Phường Chelsea'),
('PX010', 'QH007', N'Phường Santa Monica');


GO
-- Dữ liệu cho bảng NHACUNGCAP
INSERT INTO NHACUNGCAP (MaCongTy, TenCongTy, TenGiaoDich, DienThoai, Fax, Email, SoNhaTenDuong, MaPXNo) VALUES
('NCC0000001', N'VINAMILK', N'Ông Lê Văn A', '0123456789', '0123456789', 'a@company.com',N'Đường 1', 'PX001'),
('NCC0000002', N'Công ty B', N'Bà Nguyễn Bá B', '0123456788', '0123456788', 'b@company.com', N'Đường 2', 'PX003'),
('NCC0000003', N'Công ty C', N'Ông Lê Văn C', '0123456787', '0123456787', 'c@company.com',N'Đường 3', 'PX002'),
('NCC0000004', N'Công ty D', N'Bà Trần Thị D', '0123456786', '0123456786', 'd@company.com', N'Đường 4', 'PX003'),
('NCC0000005', N'Công ty E', N'Ông E', '0123456785', '0123456785', 'e@company.com',N'Đường 5', 'PX005'),
('NCC0000006', N'Công ty F', N'Bà FH', '0123456784', '0123456784', 'f@company.com', N'Đường 6', 'PX001'),
('NCC0000007', N'Công ty G', N'Ông GT', '0123456783', '0123456783', 'g@company.com',N'Đường 7', 'PX004'),
('NCC0000008', N'VINAMILK', N'Bà Chu Ngọc H', '0123456782', '0123456782', 'h@company.com', N'Đường 8', 'PX002'),
('NCC0000009', N'Công ty I', N'Ông Ih', '0123456781', '0123456781', 'i@company.com',N'Đường 9', 'PX006'),
('NCC0000010', N'Bà JM', N'Bà JM', '0123456780', '0123456780', 'j@company.com', N'Đường 10', 'PX002');

-- Dữ liệu cho bảng LOAIHANG
INSERT INTO LOAIHANG (MaLoaiHang, TenLoaiHang) VALUES
('LH00000001', N'Loại hàng A'),
('LH00000002', N'Loại hàng B'),
('LH00000003', N'Loại hàng C'),
('LH00000004', N'Loại hàng D'),
('LH00000005', N'Loại hàng E'),
('LH00000006', N'Loại hàng F'),
('LH00000007', N'Loại hàng G'),
('LH00000008', N'Loại hàng H'),
('LH00000009', N'Loại hàng I'),
('LH00000010', N'Thực Phẩm');

-- Dữ liệu cho bảng MATHANG
INSERT INTO MATHANG (MaHang, Tenhang, MaCongTyNo, MaLoaiHangNo, SoLuong, DonViTinh, GiaHang) VALUES
('MH00000001', N'Hàng A1', 'NCC0000001', 'LH00000001', 10, 'Kg', 100000),
('MH00000002', N'Hàng A2', 'NCC0000002', 'LH00000002', 20, 'Kg', 200000),
('MH00000003', N'Hàng A3', 'NCC0000003', 'LH00000003', 15, 'Kg', 150000),
('MH00000004', N'Hàng A4', 'NCC0000004', 'LH00000004', 5, 'Kg', 50000),
('MH00000005', N'Hàng A5', 'NCC0000005', 'LH00000005', 8, 'Kg', 80000),
('MH00000006', N'Hàng A6', 'NCC0000006', 'LH00000006', 12, 'Kg', 120000),
('MH00000007', N'Hàng A7', 'NCC0000007', 'LH00000007', 9, 'Kg', 90000),
('MH00000008', N'Hàng A8', 'NCC0000008', 'LH00000008', 7, 'Kg', 70000),
('MH00000009', N'Hàng A9', 'NCC0000009', 'LH00000009', 11, 'Kg', 110000),
('MH00000010', N'Hàng A10','NCC0000010', 'LH00000010', 14, 'Kg', 140000);

-- Dữ liệu cho bảng KHACHHANG
INSERT INTO KHACHHANG (MaKhachHang, TenCongTy, TenGiaoDich, Email, DienThoai, Fax, SoNhaTenDuong, MaPXNo) VALUES
('KH00000001', N'Khách A', N'Ông Lê Văn A', 'a@khach.com', '0123456789', NULL, N'Đường 1', 'PX002'),
('KH00000002', N'Công ty B', N'Bà B', 'b@khach.com', '0123456788', NULL, N'Đường 2', 'PX006'),
('KH00000003', N'VINAMILK', N'Ông A', 'c@khach.com', '0123456787', NULL, N'Đường 3', 'PX008'),
('KH00000004', N'Khách D', N'Bà Trần Thị D', 'd@khach.com', '0123456786', NULL, N'Đường 4', 'PX007'),
('KH00000005', N'Khách E', N'Ông E', 'e@khach.com', '0123456785', NULL, N'Đường 5', 'PX001'),
('KH00000006', N'Khách F', N'Bà F', 'f@khach.com', '0123456784', NULL, N'Đường 6', 'PX007'),
('KH00000007', N'Khách G', N'Ông G', 'g@khach.com', '0123456783', NULL, N'Đường 7', 'PX008'),
('KH00000008', N'Khách H', N'Bà Chu Ngọc H', 'h@khach.com', '0123456782', NULL, N'Đường 8', 'PX006'),
('KH00000009', N'Khách I', N'Ông I', 'i@khach.com', '0123456781', NULL, N'Đường 9', 'PX007'),
('KH00000010', N'Bà JM', N'Bà JM', 'j@khach.com', '0123456780', NULL, N'Đường 10', 'PX006');
-- Dữ liệu cho bảng NHANVIEN
SET DATEFORMAT dmy
INSERT INTO NHANVIEN (MaNhanVien, HO, TEN, NgaySinh, NgayLamViec, DienThoai, LuongCB, PhuCap,SoNhaTenDuong,MaPXNo) VALUES
('NV00000001', N'Nguyễn', 'A', '01-01-2000', '01-01-2020', '0123456789', 5000000, default,N'123 Tôn Đực Thắng', 'PX001'),
('NV00000002', N'Trần', 'B', '01-01-1995', '01-01-2019', '0123456788', 5500000, 1200000,N'02 Nguyễn Tri Phương', 'PX002'),
('NV00000003', N'Lê', 'C', '01-01-1980', '01-01-2021', '0123456787', 6000000, 1500000,N'12 Phạm Ngũ Lão', 'PX003'),
('NV00000004', N'Phạm', 'D', '01-01-1990', '01-01-2022', '0123456786', 5200000, 1100000,N'01 Lê Độ', 'PX004'),
('NV00000005', N'Ngô', 'E', '01-01-1998', '01-01-2023', '0123456785', 5300000, 1150000,N'18 Trần Cao Vân', 'PX005'),
('NV00000006', N'Vũ', 'F', '01-01-1985', '01-01-2020', '0123456784', 5900000, 1300000,N'250 Hà Huy Tập', 'PX003'),
('NV00000007', N'Đỗ', 'G', '01-01-1992', '01-01-2018', '0123456783', 5400000, 1250000,N'10 Giải Phóng', 'PX002'),
('NV00000008', N'Bùi', 'H', '01-01-1975', '01-01-2016', '0123456782', 6100000, 1400000,N'08 Bạch Đừng', 'PX001'),
('NV00000009', N'Nguyễn', 'I', '01-01-1988', '01-01-2017', '0123456781', 5700000, default,N'15 Đỗ Quang', 'PX007'),
('NV00000010', N'Trần', 'J', '01-01-1993', '01-01-2023', '0123456780', 5800000, 1450000,N'30 Điên Biên Phủ', 'PX003');
SET DATEFORMAT dmy
INSERT INTO DONDATHANG (SoHoaDon,MaKhachHangNo,MaNhanVienNo,NgayDatHang,NgayChuyenHang,NgayGiaoHang,SoNhaTenDuong,MaPXNo)VALUES
('DH00000001', 'KH00000001', 'NV00000001', '01-02-2022','10-02-2022', '20-02-2022', NULL, 'PX001'),
('DH00000002', 'KH00000002', 'NV00000002', GETDATE(), GETDATE()+11, GETDATE()+21, N'456 Đường B', 'PX002'),
('DH00000003', 'KH00000003', 'NV00000003', '05-04-2022', '10-05-2022', '10-05-2022', NULL, NULL),
('DH00000004', 'KH00000004', 'NV00000003', GETDATE(), GETDATE()+12, GETDATE()+22, N'101 Đường D', 'PX004'),
('DH00000005', 'KH00000005', 'NV00000005', '10-03-2022', '20-03-2022','30-04-2022', N'112 Đường E', 'PX005'),
('DH00000006', 'KH00000006', 'NV00000006', GETDATE(), Null, GETDATE()+24, N'131 Đường F', 'PX006'),
('DH00000007', 'KH00000007', 'NV00000006', GETDATE(), GETDATE()+15, GETDATE()+25, N'415 Đường G', 'PX007'),
('DH00000008', 'KH00000008', 'NV00000008', '01-03-2023', '01-05-2023', '10-10-2023', N'161 Đường H', 'PX008'),
('DH00000009', 'KH00000009', 'NV00000009', GETDATE(), GETDATE()+17, GETDATE()+27, N'718 Đường I', 'PX009'),
('DH00000010', 'KH00000010', 'NV00000009', GETDATE(), null, GETDATE()+28, N'910 Đường J', 'PX010');

--Dữ liệu cho bảng CHITIETDATHANG
INSERT INTO CHITIETDATHANG (SoHoaDonNo, MaHangNo, GiaBan, SoLuong, MucGiamGia) VALUES
('DH00000001', 'MH00000001', 100000, 2, 0.5),
('DH00000001', 'MH00000002', 200000, 100, Default),
('DH00000002', 'MH00000002', 150000, 3, 0.2),
('DH00000002', 'MH00000004', 50000, 4, Default),
('DH00000003', 'MH00000005', 80000, 1, 0.1),
('DH00000003', 'MH00000004', 120000, 100, 0.3),
('DH00000004', 'MH00000005', 90000, 1, Default),
('DH00000008', 'MH00000008', 70000, 110, Default),
('DH00000005', 'MH00000008', 110000, 100, 0.1),
('DH00000005', 'MH00000010', 140000, 2, Default);

------------INSERT VALUE--------------
--Phúc An
-- a.Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
UPDATE DONDATHANG
SET NGAYCHUYENHANG = NGAYDATHANG
WHERE NGAYCHUYENHANG IS NULL;

--b. Tăng số lượng hàng của những mặt hàng do công ty VINAMILK cung cấp lên gấp đôi.
UPDATE MATHANG
SET SoLuong = SoLuong * 2
FROM MATHANG, NHACUNGCAP
WHERE MaCongTyNo = MaCongTy AND TenCongTy = 'VINAMILK'

/*
	UPDATE MATHANG
	SET SOLUONG = SOLUONG * 2
	WHERE MaCongTyNo in (SELECT MACONGTY 
							FROM NHACUNGCAP
							WHERE TENCONGTY = 'VINAMILK')
*/

-- c.Cập nhật giá trị của trường NOIGIAOHANG trong bảng DONDATHANG bằng địa chỉ của khách hàng đối với những đơn đặt hàng chưa xác định được nơi giao hàng (giá trị trường NOIGIAOHANG bằng NULL).				 
UPDATE DONDATHANG 
SET DONDATHANG.SoNhaTenDuong = (
    SELECT k.SoNhaTenDuong
    FROM KHACHHANG k
    WHERE k.MaKhachHang = DONDATHANG.MaKhachHangNo
)
WHERE DONDATHANG.SoNhaTenDuong IS NULL;

--Quách Tỉnh
--d.Cập nhật lại dữ liệu trong bảng KHACHHANG sao cho nếu tên công ty và tên giao dịch của khách hàng trùng với tên công ty và tên giao dịch của một nhà cung cấp nào đó thì địa chỉ, điện thoại, Fax và e-mail phải giống nhau.
UPDATE KHACHHANG
SET	SoNhaTenDuong = n.SoNhaTenDuong, MaPXNo = n.MaPXNo, EMAIL = n.EMAIL, DIENTHOAI = n.DIENTHOAI, FAX = n.FAX
FROM dbo.NHACUNGCAP n, KHACHHANG k
WHERE n.TenGiaoDich = K.TenCongTy AND n.TenGiaoDich = K.TenGiaoDich

select *from KHACHHANG

-- e.Tăng lương lên gấp rưỡi cho những nhân viên bán được số lượng hàng nhiều hơn 100 trong năm 2022.
UPDATE NHANVIEN
SET LUONGCB=LUONGCB*2
WHERE MaNhanVien IN (
    SELECT DH.MaNhanVienNo
    FROM DONDATHANG as DH,CHITIETDATHANG as CTDH 
    WHERE  year(DH.NgayGiaoHang) ='2022'  
    GROUP BY DH.MaNhanVienNo
    HAVING Sum(CTDH.SoLuong)>100
)

--Văn Vũ
--f. Tăng phụ cấp lên bằng 50% lương cho những nhân viên bán được hàng nhiều nhất.
UPDATE NHANVIEN
SET PHUCAP = LuongCB * 0.5
WHERE MaNhanVien in (
    SELECT TOP 1 MaNhanVienNo
    FROM (
        SELECT MaNhanVienNo, SUM(SoLuong) AS TongSL
        FROM DONDATHANG, CHITIETDATHANG
        WHERE SoHoaDonNo = SoHoaDon
        GROUP BY MaNhanVienNo
    ) AS Temp
    ORDER BY TongSL DESC
);

--g. Giảm 25% lương của những nhân viên trong năm 2024 không lập được bất kỳ đơn đặt hàng nào.
UPDATE NHANVIEN
SET LuongCB = LuongCB * 0.75
WHERE MaNhanVien NOT IN (
    SELECT MaNhanVienNo
    FROM DONDATHANG
    WHERE YEAR(NGAYDATHANG) = 2024
);

----------------------------- Bài Tập nhóm ---------------------------
-- 1
UPDATE NHACUNGCAP
SET TenGiaoDich=N'VINAMILK'
WHERE MaCongTy IN('NCC0000004','NCC0000005')

SELECT NCC.MaCongTy,NCC.TenCongTy,NCC.DienThoai,NCC.SoNhaTenDuong+' '+PX.TenPX+' '+QH.TenQuanHuyen+' '+TTP.TenTinhTP+' '+QG.TenQuocGia
FROM NHACUNGCAP as NCC ,PHUONGXA as PX,QUANHUYEN as QH,TINHTP as TTP,QUOCGIA as QG
WHERE  NCC.MaPXNo=PX.MaPX AND PX.MaQHNO=QH.MaQH AND QH.MaTTPNO=TTP.MaTTP AND TTP.MaQGNo=QG.MaQG AND NCC.TenGiaoDich='VINAMILK'

-- 2
SELECT Lh.TenLoaiHang,NCC.MaCongTy,NCC.TenCongTy,NCC.SoNhaTenDuong+' '+PX.TenPX+' '+QH.TenQuanHuyen+' '+TTP.TenTinhTP+' '+QG.TenQuocGia as [DiaChi]
FROM LOAIHANG as LH
JOIN MATHANG as MH ON MH.MaLoaiHangNo=LH.MaLoaiHang
JOIN NHACUNGCAP as NCC ON NCC.MaCongTy=MH.MaCongTyNo
JOIN PHUONGXA as PX ON Px.MaPX=Ncc.MaPXNo
JOIN QUANHUYEN as Qh ON QH.MaQH=PX.MaQHNO
JOIN TINHTP as TTP ON TTP.MaTTP=QH.MaTTPNO
JOIN QUOCGIA as QG ON QG.MaQG=TTP.MaQGNO

-- 3
select *
from MATHANG
UPDATE MATHANG
SET Tenhang =N'Sữa hộp VINAMILK'
WHERE  MaHang in ('MH00000008')

select *
from MATHANG
UPDATE MATHANG
SET Tenhang =N'Sữa hộp NutiMilk'
WHERE  MaHang in ('MH00000006')

SELECT KH.*,MH.Tenhang
FROM KHACHHANG as KH
JOIN DONDATHANG as DH ON DH.MaKhachHangNo=KH.MaKhachHang
JOIN CHITIETDATHANG as CTDH ON CTDH.SoHoaDonNo=DH.SoHoaDon
JOIN MATHANG as MH ON MH.MaHang=CTDH.MaHangNo
WHERE MH.Tenhang like(N'Sữa hộp%')

-- 4
SELECT DH.*,NCC.TenCongTy
FROM DONDATHANG as DH 
JOIN CHITIETDATHANG as CTDH ON CTDH.SoHoaDonNo=DH.SoHoaDon
JOIN MATHANG as MH ON MH.MaHang=CTDH.MaHangNo
JOIN NHACUNGCAP as NCC ON NCC.MaCongTy=MH.MaCongTyNo
WHERE DH.NgayDatHang=DH.NgayGiaoHang

------------------------------------ Bổ sung: Bài Tập Nhóm - 13/11/2024 ----------------------------
-- CÂU 5: TỔNG SỐ TIỀN MÀ KHÁCH HÀNG PHẢI TRẢ CHO MỖI ĐƠN HÀNG LÀ BAO NHIÊU
SELECT SoHoaDon, TenCongTy, SUM(SoLuong * GiaBan) AS 'Tổng Tiền Khách Trả'
FROM DONDATHANG
JOIN KHACHHANG ON MaKhachHangNo = MaKhachHang
JOIN CHITIETDATHANG ON SoHoaDon = SoHoaDonNo
GROUP BY SoHoaDon, TenCongTy;

-- CÂU 6: HÃY CHO BIẾT TỔNG SỐ TIỀN LỜI MÀ CÔNG TY THU ĐƯỢC TỪ MỖI MẶT HÀNG TRONG NĂM 2024
SELECT MH.MaHang, MH.TenHang, 
    SUM(CTDH.SoLuong * (CTDH.GiaBan - (CTDH.GiaBan * CTDH.MucGiamGia / 100))) AS 'Tổng Tiền Lời'
FROM DONDATHANG DH
INNER JOIN CHITIETDATHANG CTDH ON DH.SoHoaDon = CTDH.SoHoaDonNo  
INNER JOIN MATHANG MH ON CTDH.MaHangNo = MH.MaHang
WHERE YEAR(DH.NgayDatHang) = 2024 
GROUP BY MH.MaHang, MH.TenHang;
-------------------------Bài tập nhóm tuần 11--------------
--Văn Minh
--Câu 1.Cho biết danh sách các đối tác cung cấp hàng cho công ty
SELECT MaCongTy, TenCongTy, TenGiaoDich, DienThoai, Email,(NCC.SoNhaTenDuong +','+ PX.TenPX +','+ QH.TenQuanHuyen +','+ TTP.TenTinhTP +','+ QG.TenQuocGia) as [Địa Chỉ]
FROM NHACUNGCAP as NCC,PHUONGXA as PX,QUANHUYEN as QH,TINHTP as TTP,QUOCGIA as QG
WHERE NCC.MaPXNo=PX.MaPX AND PX.MaQHNO=QH.MaQH AND QH.MaTTPNO=TTP.MaTTP AND TTP.MaQGNo=QG.MaQG

--Câu 2: Mã hàng, tên hàng và số lượng của các mặt hàng hiện có trong công ty.
SELECT MaHang, Tenhang, SoLuong
FROM MATHANG;

-- Câu 3.Họ tên và địa chỉ và năm bắt đầu làm việc của các nhân viên trong công ty
SELECT NV.MaNhanVien ,(NV.HO +' '+ NV.TEN) as [Họ và Tên],(NV.SoNhaTenDuong +','+ PX.TenPX +','+ QH.TenQuanHuyen +','+ TTP.TenTinhTP +','+ QG.TenQuocGia) as [Địa Chỉ],YEAR(NgayLamViec) AS NamBatDau
FROM NHANVIEN as NV,PHUONGXA as PX,QUANHUYEN as QH,TINHTP as TTP,QUOCGIA as QG
WHERE NV.MaPXNo=PX.MaPX AND PX.MaQHNO=QH.MaQH AND QH.MaTTPNO=TTP.MaTTP AND TTP.MaQGNo=QG.MaQG

select *
from NHANVIEN
--Câu 4.Địa chỉ và điện thoại của nhà cung cấp có tên giao dịch [VINAMILK]  là gì?
SELECT NCC.MaCongTy,NCC.TenCongTy,NCC.DienThoai,(NCC.SoNhaTenDuong+' '+PX.TenPX+' '+QH.TenQuanHuyen+' '+TTP.TenTinhTP+' '+QG.TenQuocGia) as [Địa chỉ]
FROM NHACUNGCAP as NCC
JOIN PHUONGXA as PX ON PX.MaPX=NCC.MaPXNo
JOIN QUANHUYEN as QH ON QH.MaQH=PX.MaQHNO
JOIN TINHTP as TTP ON TTP.MaTTP=QH.MaTTPNO
JOIN QUOCGIA as QG ON QG.MaQG=TTP.MaQGNo
WHERE  NCC.TenGiaoDich='VINAMILK'

--Phúc An
--5.	Cho biết mã và tên của các mặt hàng có giá lớn hơn 100000 và số lượng hiện có ít hơn 50
select MaHang, Tenhang 
from MATHANG
where GiaHang > 100000 and SoLuong < 50

--6.	Cho biết mỗi mặt hàng trong công ty do ai cung cấp
select mh.MaHang, mh.Tenhang, ncc.TenCongTy
from MATHANG mh, NHACUNGCAP ncc
where mh.MaCongTyNo = ncc.MaCongTy

-- Câu 7. Công ty [Việt Tiến] đã cung cấp những mặt hàng nào?
UPDATE NHACUNGCAP
SET TenCongTy=N'Việt Tiến'
WHERE MaCongTy in ('NCC0000008','NCC0000006')

SELECT MH.*,NCC.TenCongTy
FROM MATHANG as MH,NHACUNGCAP as NCC
WHERE MH.MaCongTyNo=NCC.MaCongTy AND NCC.TenCongTy=N'Việt Tiến'
-- Câu 8.Loại hàng thực phẩm do những công ty nào cung cấp và địa chỉ của các công ty đó là gì?
SELECT distinct Lh.TenLoaiHang,NCC.MaCongTy,NCC.TenCongTy,( NCC.SoNhaTenDuong+' '+PX.TenPX+' '+QH.TenQuanHuyen+' '+TTP.TenTinhTP+' '+QG.TenQuocGia) as [DiaChi]
FROM LOAIHANG as LH
JOIN MATHANG as MH ON MH.MaLoaiHangNo=LH.MaLoaiHang
JOIN NHACUNGCAP as NCC ON NCC.MaCongTy=MH.MaCongTyNo
JOIN PHUONGXA as PX ON Px.MaPX=Ncc.MaPXNo
JOIN QUANHUYEN as Qh ON QH.MaQH=PX.MaQHNO
JOIN TINHTP as TTP ON TTP.MaTTP=QH.MaTTPNO
JOIN QUOCGIA as QG ON QG.MaQG=TTP.MaQGNO
Where Lh.TenLoaiHang = N'Thực phẩm'

-- Câu 9.Những khách hàng nào (tên giao dịch) đã đặt mua mặt hàng Sữa hộp XYZ của công ty?
SELECT distinct MaKhachHang, TenGiaoDich, TenHang
FROM KHACHHANG as KH
JOIN DONDATHANG as DH ON DH.MaKhachHangNo=KH.MaKhachHang
JOIN CHITIETDATHANG as CTDH ON CTDH.SoHoaDonNo=DH.SoHoaDon
JOIN MATHANG as MH ON MH.MaHang=CTDH.MaHangNo
WHERE MH.Tenhang like(N'Sữa hộp%')

--10.	Đơn đặt hàng số 1 do ai đặt và do nhân viên nào lập, thời gian và địa điểm giao hàng là ở đâu?
select k.MaKhachHang, k.TenCongTy ,nv.MANHANVIEN, CONCAT(nv.HO,' ',nv.TEN) as HoTen, NGAYGIAOHANG, ddh.SONHATENDUONG, px.TENPX, qh.TENQUANHUYEN, tt.TENTINHTP, qg.TENQUOCGIA
from DONDATHANG ddh, NHANVIEN nv, PHUONGXA px, QUANHUYEN qh, TINHTP tt, QUOCGIA qg, KHACHHANG k
where ddh.MaNhanVienNo = nv.MANHANVIEN and ddh.MaPXNo = px.MAPX and px.MAQHNO = qh.MAQH and qh.MATTPNO = tt.MATTP and tt.MAQGNO = qg.MAQG and  k.MaKhachHang = ddh.MaKhachHangNo and ddh.SoHoaDon = 'DH00000001'

select * from DONDATHANG
-- Văn Vũ
-- Câu 11: Hãy cho biết số tiền lương mà công ty phải trả cho mỗi nhân viên là bao nhiêu (lương = lương cơ bản + phụ cấp).
SELECT MaNhanVien, Ho+' '+Ten as 'Tên Nhân Viên', LuongCB, PhuCap, (LuongCB + PhuCap) AS 'Lương'
FROM NHANVIEN

-- Câu 12. Hãy cho biết có những khách hàng nào lại chính là đối tác cung cấp hàng của công ty (tức là có cùng tên giao dịch).
SELECT  KH.*
FROM KHACHHANG as KH, NHACUNGCAP as NCC
WHERE KH.TenGiaoDich = NCC.TenGiaoDich

-- Câu 13: Trong công ty có những nhân viên nào có cùng ngày sinh?
SELECT MANHANVIEN, HO + ' ' + TEN AS 'TÊN NHÂN VIÊN', NGAYSINH
FROM NHANVIEN
WHERE 
    DAY(NGAYSINH) IN (
        SELECT DAY(NGAYSINH)
        FROM NHANVIEN
        GROUP BY DAY(NGAYSINH)
        HAVING COUNT(*) > 1
    )
ORDER BY NGAYSINH;


-- Câu 14: Những đơn đặt hàng nào yêu cầu giao hàng ngay tại công ty đặt hàng và những đơn đó là của công ty nào?
-- Xóa dữ liệu đã insert trước là DH11, DH12, DH13, DH14
DELETE FROM DONDATHANG 
WHERE SoHoaDon in ('DH00000011', 'DH00000012', 'DH00000013', 'DH00000014');

-- Thêm lại dữ liệu vào bảng DONDATHANG và CHITIETDONHANG
SET DATEFORMAT dmy
INSERT INTO DONDATHANG (SoHoaDon,MaKhachHangNo,MaNhanVienNo,NgayDatHang,NgayChuyenHang,NgayGiaoHang,SoNhaTenDuong,MaPXNo)VALUES
('DH00000015', 'KH00000002', 'NV00000008', GETDATE()+3, GETDATE()+3, GETDATE()+3, N'556 Đường CDT', 'PX009'),
('DH00000016', 'KH00000003', 'NV00000004', GETDATE()+3, GETDATE()+3, GETDATE()+3, N'889 Đường TDH', 'PX008'),
('DH00000017', 'KH00000010', 'NV00000001', GETDATE()+2, GETDATE()+2, GETDATE()+2, N'756 Đường ABC', 'PX008'),
('DH00000018', 'KH00000004', 'NV00000003', GETDATE()+2, GETDATE()+2, GETDATE()+2, N'189 Đường QL1A', 'PX002');

INSERT INTO CHITIETDATHANG (SoHoaDonNo, MaHangNo, GiaBan, SoLuong, MucGiamGia) VALUES
('DH00000015', 'MH00000009', 1150000, 3, default),
('DH00000016', 'MH00000010', 1500000, 2, default),
('DH00000017', 'MH00000005', 125000, 3, default),
('DH00000018', 'MH00000004', 65000, 2, default);

SELECT DH.SoHoaDon, DH.NgayDatHang, DH.NgayGiaoHang, NCC.TenCongTy
FROM DONDATHANG AS DH 
JOIN CHITIETDATHANG AS CTDH ON CTDH.SoHoaDonNo = DH.SoHoaDon
JOIN MATHANG AS MH ON MH.MaHang = CTDH.MaHangNo
JOIN NHACUNGCAP AS NCC ON NCC.MaCongTy = MH.MaCongTyNo
WHERE DH.NgayDatHang = DH.NgayGiaoHang;

--Quách Tỉnh
-- Câu 15: Cho biết tên công ty,  tên giao dịch, địa chỉ và điện thoại của các khách hàng và các nhà cung cấp hàng cho công ty.
SELECT DISTINCT n.TENCONGTY "Tên công ty",n.TENGIAODICH "Tên giao dịch",CONCAT(k.SONHATENDUONG, ',', TENPX, ',', TenQuanHuyen,',',TenTinhTP,',',TenQuocGia)  "Địa chỉ khách hàng",k.DIENTHOAI   "Số điện thoại khách hàng"
,CONCAT(n.SONHATENDUONG, ',', TENPX, ',', TenQuanHuyen,',',TenTinhTP,',',TenQuocGia)  "Địa chỉ nhà cung cấp",n.DIENTHOAI   "Số điện thoại nhà cung cấp"
FROM NHACUNGCAP n
JOIN PHUONGXA p ON p.MaPX = n.MaPXNo
JOIN  KHACHHANG k ON p.MaPX =k.MaPXNo
JOIN QUANHUYEN  ON MAQH = MaQHNO
JOIN TINHTP  ON MaTTP = MaTTPNO
JOIN QUOCGIA  ON MAQG = MAQGNo
JOIN DONDATHANG d ON d.MaKhachHangNo = k.MAKHACHHANG
JOIN MATHANG m ON m.MaCongTyNo = n.MACONGTY

--Câu 16:Những mặt hàng nào chưa từng được khách hàng đặt mua?
SELECT MH.*
FROM MATHANG as MH
LEFT JOIN CHITIETDATHANG as CTDH ON CTDH.MaHangNo=MH.MaHang
WHERE CTDH.MaHangNo IS NULL

--17.Những nhân viên nào của công ty chưa từng lập bất kỳ một hoá đơn đặt hàng nào?
SELECT NV.*
FROM NHANVIEN as NV 
LEFT JOIN DONDATHANG as DH ON DH.MaNhanVienNo=NV.MaNhanVien
WHERE DH.MaNhanVienNo IS NULL

-- 18.Những nhân viên nào của công ty có lương cơ bản cao nhất?
SELECT *
FROM NHANVIEN as NV 
WHERE LuongCB = (
	SELECT MAX(LuongCB)
	FROM NHANVIEN
)

---------------------------------------------- Bài Nhóm Về Hàm, Thủ Tục và Trigger -------------------------------------
-- 1. Tạo thủ tục lưu trữ để thông qua thủ tục này có thể bổ sung thêm một bản ghi mới cho bảng MATHANG 
	  --(thủ tục phải thực hiện kiểm tra tính hợp lệ của dữ liệu cần bổ sung: không trùng khoá chính và đảm bảo toàn vẹn tham chiếu) 
go
CREATE PROCEDURE ThemMatHang
    @MaHang CHAR(10),
    @TenHang NVARCHAR(30),
    @MaCongTyNo CHAR(10),
    @MaLoaiHangNo CHAR(10),
    @SoLuong INT,
    @DonViTinh NVARCHAR(20),
    @GiaHang money
AS
BEGIN
    IF EXISTS (SELECT * FROM MATHANG WHERE MaHang = @MaHang)
    BEGIN
		RAISERROR('Mã mặt hàng đã tồn tại.', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT * FROM MATHANG WHERE MaCongTyNo = @MaCongTyNo)
    BEGIN
		RAISERROR('Mã công ty không tồn tại.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM MATHANG WHERE MaLoaiHangNo = @MaLoaiHangNo)
    BEGIN
		RAISERROR('Mã loại hàng không tồn tại.', 16, 1);
        RETURN;
    END
	IF @SOLUONG < 0  
    BEGIN  
        RAISERROR('Số lượng không thể là giá trị âm', 16, 1);  
        RETURN;  
    END 
	IF @GIAHANG < 0  
    BEGIN  
        RAISERROR('Giá hàng không thể là giá trị âm', 16, 1);  
        RETURN
    END 

    -- Thêm bản ghi mới
    INSERT INTO MATHANG (MaHang, TenHang, MaCongTyNo, MaLoaiHangNo, SoLuong, DonViTinh, GiaHang)
    VALUES (@MaHang, @TenHang, @MaCongTyNo, @MaLoaiHangNo, @SoLuong, @DonViTinh, @GiaHang);
END;
go
EXEC ThemMatHang 
    @MaHang = 'MH00000011',
    @TenHang = N'Hàng A11',
    @MaCongTyNo = 'NCC0000010',
    @MaLoaiHangNo = 'LH00000010',
    @SoLuong = 10,
    @DonViTinh = 'Kg',
    @GiaHang = 150000;

-- 2. Tạo thủ tục lưu trữ có chức năng thống kê tổng số lượng hàng bán được của một mặt hàng có mã bất kỳ 
      --(mã mặt hàng cần thống kê là tham số của thủ tục). 
GO
DROP PROC IF EXISTS pr_ThongKeSoLuongBan;
GO

CREATE PROC pr_ThongKeSoLuongBan
    @MaMatHang CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem mặt hàng có tồn tại trong bảng MATHANG hay không
    IF NOT EXISTS (SELECT * FROM MATHANG WHERE MAHANG = @MaMatHang)
    BEGIN
        RAISERROR('Mặt hàng này chưa được cung cấp!', 16, 1);
        RETURN; -- Thoát khỏi thủ tục nếu mặt hàng không tồn tại
    END

    SELECT 
        @MaMatHang AS MaMatHang,
        ISNULL(SUM(CTDH.SOLUONG), 0) AS TongSoLuongBan
    FROM 
        CHITIETDATHANG CTDH
    WHERE 
        CTDH.MaHangNo = @MaMatHang;

END
GO

-- Gọi thủ tục với mã hàng không tồn tại
EXEC pr_ThongKeSoLuongBan @MaMatHang = 'MH00000011';
GO

-- Gọi thủ tục với mã hàng tồn tại
EXEC pr_ThongKeSoLuongBan @MaMatHang = 'MH00000005';

-- 3. Viết hàm trả về một bảng trong đó cho biết tổng số lượng hàng bán được của mỗi mặt hàng. 
      --Sử dụng hàm này để thống kê xem tổng số lượng hàng (hiện có và đã bán) của mỗi mặt hàng là bao nhiêu.
GO
DROP FUNCTION IF EXISTS fn_TongSoLuongHangBan;
GO

CREATE FUNCTION fn_TongSoLuongHangBan()
RETURNS TABLE
AS
RETURN (
    SELECT 
        M.MAHANG,
        M.TENHANG,
        COALESCE(SUM(C.SOLUONG), 0) AS TongSoLuongBan,
        M.SOLUONG AS SoLuongHienCo
    FROM 
        MATHANG M
    LEFT JOIN 
        CHITIETDATHANG C ON M.MAHANG = C.MaHangNo
    GROUP BY 
        M.MAHANG, M.TENHANG, M.SOLUONG
);
GO
SELECT *
FROM dbo.fn_TongSoLuongHangBan();

-- 4 Viết trigger cho bảng CHITIETDATHANG theo yêu cầu sau: 
GO
CREATE FUNCTION Fn_TangTuDongID_DonDatHang
()
RETURNS char(10)
BEGIN
	declare @next int
    declare @values char(10)
    SELECT @next=max(RIGHT(SoHoaDon,2))+1
    FROM DONDATHANG as PN
    SET @values = 'DH00000' + RIGHT('000' + CAST(@next AS VARCHAR), 3);
    RETURN @values
END

GO

CREATE TRIGGER Tr_DatHang
ON CHITIETDATHANG
INSTEAD OF INSERT
AS 
BEGIN
	declare @soLuong1 int,@soLuong2 int 
	select @soLuong1=MATHANG.SoLuong,@soLuong2=i.SoLuong
	from MATHANG,inserted i
	WHERE i.MaHangNo=MATHANG.MaHang

	if(@soLuong2>@soLuong1)
	BEGIN
		print N'Số lượng hiện có trong MATHANG không đủ'
		return
	END
	ELSE
	BEGIN
		INSERT INTO CHITIETDATHANG (SoHoaDonNo, MaHangNo, GiaBan, SoLuong)
        SELECT i.SoHoaDonNo, i.MaHangNo, i.GiaBan, i.SoLuong
        FROM inserted i;

		UPDATE CHITIETDATHANG
		SET CHITIETDATHANG.GiaBan=MH.GiaHang
		FROM inserted i ,MATHANG MH
		WHERE i.MaHangNo=CHITIETDATHANG.MaHangNo AND MH.MaHang=i.MaHangNo

		UPDATE MATHANG
		SET MATHANG.SoLuong=MATHANG.SoLuong-i.SoLuong
		FROM inserted i 
		WHERE i.MaHangNo=MATHANG.MaHang
	END

END

go

DECLARE @maDH char(10)
SET @maDH=dbo.Fn_TangTuDongID_DonDatHang()
INSERT INTO DONDATHANG(SoHoaDon,MaKhachHangNo,MaNhanVienNo,NgayDatHang,NgayGiaoHang,NgayChuyenHang,SoNhaTenDuong,MaPXNo)
VALUES(@maDH,'KH00000002','NV00000004',GETDATE(),GETDATE()+10,GETDATE()+15,'12 Trần Cao Vân','PX002')
INSERT INTO CHITIETDATHANG (SoHoaDonNo, MaHangNo, GiaBan, SoLuong,MucGiamGia)
VALUES(@maDH,'MH00000010',NULL,10,0.0)

GO
CREATE TRIGGER Tr_CapNhatHang
ON CHITIETDATHANG
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM MATHANG MH
        JOIN inserted i ON MH.MaHang = i.MaHangNo
        JOIN deleted d ON MH.MaHang = d.MaHangNo
        WHERE (MH.SoLuong + d.SoLuong) < i.SoLuong OR i.SoLuong < 1
    )
    BEGIN
		SELECT MH.MaHang,
			CASE 
				WHEN (MH.SoLuong + d.SoLuong) < i.SoLuong THEN N'Số lượng không đủ'
				WHEN i.SoLuong < 1 THEN N'Số lượng đặt nhỏ hơn 1'
			END AS KiemTraSoLuong
		FROM MATHANG MH
		JOIN inserted i ON MH.MaHang = i.MaHangNo
		JOIN deleted d ON MH.MaHang = d.MaHangNo;
        -- ROLLBACK TRANSACTION
        RETURN
    END
	ELSE
	BEGIN
		UPDATE MATHANG
		SET SoLuong=MATHANG.SoLuong+d.SoLuong-i.SoLuong
		FROM inserted i,deleted d
		WHERE d.MaHangNo=MaHang AND d.MaHangNo=i.MaHangNo

	END
END
GO

UPDATE CHITIETDATHANG
SET SoLuong=5
WHERE MaHangNo='MH00000001' AND SoHoaDonNo='DH00000001'