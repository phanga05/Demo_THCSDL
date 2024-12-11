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
	PhuCap money ,
)
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
		on delete cascade
		on update cascade
)
create table QUANHUYEN
(
    MaQH char(5) PRIMARY KEY,
    MaTTPNO char(5),
    TenQuanHuyen nvarchar(50),
	CONSTRAINT FK_QUANHUYEN FOREIGN KEY(MaTTPNO) REFERENCES TINHTP(MaTTP)
		on delete cascade
		on update cascade
)
create table PHUONGXA
(
    MaPX char(5) PRIMARY KEY,
    MaQHNO char(5),
    TenPX nvarchar(50),
    CONSTRAINT FK_PHUONGXA FOREIGN KEY(MaQHNO) REFERENCES QUANHUYEN(MaQH)
		on delete cascade
		on update cascade
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
        MaPXNo CHAR(5)
		CONSTRAINT FK_NHACUNGCAP_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX);
GO
-- Bảng KHACHHANG
ALTER TABLE KHACHHANG
    ADD SoNhaTenDuong NVARCHAR(50),
        MaPXNo CHAR(5)
		CONSTRAINT FK_KHACHHANG_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX)
GO
--Bang DONDATHANG
ALTER TABLE DONDATHANG
    ADD SoNhaTenDuong NVARCHAR(50),
        MaPXNo CHAR(5)
		CONSTRAINT FK_DONDATHANG_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX)

GO
--Bang NhanVien
ALTER TABLE NhanVien
    ADD soNhaTenDuong NVARCHAR(50),
        maPXNo CHAR(5)
		CONSTRAINT FK_NhanVien_MaPXNo FOREIGN KEY (MaPXNo) REFERENCES PHUONGXA(MaPX)

GO

------------------------INSERT VALUE-----------------------
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

-- Dữ liệu cho bảng NHACUNGCAP
INSERT INTO NHACUNGCAP (MaCongTy, TenCongTy, TenGiaoDich, DienThoai, Fax, Email, SoNhaTenDuong, MaPXNo) VALUES
('NCC0000001', N'VINAMILK', N'Ông E', '0123456789', '0123456789', 'a@company.com',N'Đường 1', 'PX001'),
('NCC0000002', N'Công ty B', N'Bà H', '0123456788', '0123456788', 'b@company.com', N'Đường 2', 'PX003'),
('NCC0000003', N'Bà C', N'Ông C', '0123456787', '0123456787', 'c@company.com',N'Đường 3', 'PX002'),
('NCC0000004', N'Công ty D', N'Bà D', '0123456786', '0123456786', 'd@company.com', N'Đường 4', 'PX003'),
('NCC0000005', N'Công ty Thép', N'Ông E', '0123456785', '0123456785', 'e@company.com',N'Đường 5', 'PX005'),
('NCC0000006', N'Công ty F', N'Bà K', '0123456784', '0123456784', 'f@company.com', N'Đường 6', 'PX001'),
('NCC0000007', N'Công ty G', N'Ông G', '0123456783', '0123456783', 'g@company.com',N'Đường 7', 'PX004'),
('NCC0000008', N'Công ty H', N'Bà C', '0123456782', '0123456782', 'h@company.com', N'Đường 8', 'PX002'),
('NCC0000009', N'Công ty I', N'Ông I', '0123456781', '0123456781', 'i@company.com',N'Đường 9', 'PX006'),
('NCC0000010', N'Công ty J', N'Bà J', '0123456780', '0123456780', 'j@company.com', N'Đường 10', 'PX002');

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
('LH00000010', N'Loại hàng J');

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
('KH00000001', N'Khách A', 'Ông A', 'a@khach.com', '0123456789', NULL, N'Đường 1', 'PX002'),
('KH00000002', N'Công ty B', 'Bà B', 'b@khach.com', '0123456788', NULL, N'Đường 2', 'PX006'),
('KH00000003', N'Khách C', 'Ông C', 'c@khach.com', '0123456787', NULL, N'Đường 3', 'PX008'),
('KH00000004', N'Khách D', 'Bà D', 'd@khach.com', '0123456786', NULL, N'Đường 4', 'PX007'),
('KH00000005', N'Khách E', 'Ông E', 'e@khach.com', '0123456785', NULL, N'Đường 5', 'PX001'),
('KH00000006', N'Khách F', 'Bà F', 'f@khach.com', '0123456784', NULL, N'Đường 6', 'PX007'),
('KH00000007', N'Khách G', 'Ông G', 'g@khach.com', '0123456783', NULL, N'Đường 7', 'PX008'),
('KH00000008', N'Khách H', 'Bà H', 'h@khach.com', '0123456782', NULL, N'Đường 8', 'PX006'),
('KH00000009', N'Khách I', 'Ông I', 'i@khach.com', '0123456781', NULL, N'Đường 9', 'PX007'),
('KH00000010', N'Khách J', 'Bà J', 'j@khach.com', '0123456780', NULL, N'Đường 10', 'PX006');

-- Dữ liệu cho bảng NHANVIEN
SET DATEFORMAT dmy
INSERT INTO NHANVIEN (MaNhanVien, HO, TEN, NgaySinh, NgayLamViec, DienThoai, LuongCB, PhuCap, SoNhaTenDuong, MaPXNo) VALUES
('NV00000001', N'Nguyễn', 'A', '01-01-2000', '01-01-2020', '0123456789', 5000000, 1000000, N'123 Đường X', 'PX001'),
('NV00000002', N'Trần', 'B', '01-01-1995', '01-01-2019', '0123456788', 5500000, 1200000, N'456 Đường Y', 'PX002'),
('NV00000003', N'Lê', 'C', '01-01-1980', '01-01-2021', '0123456787', 6000000, 1500000, N'789 Đường Z', 'PX003'),
('NV00000004', N'Phạm', 'D', '01-01-1990', '01-01-2022', '0123456786', 5200000, 1100000, N'101 Đường A', 'PX004'),
('NV00000005', N'Ngô', 'E', '01-01-1998', '01-01-2023', '0123456785', 5300000, 1150000, N'202 Đường B', 'PX005'),
('NV00000006', N'Vũ', 'F', '01-01-1985', '01-01-2020', '0123456784', 5900000, 1300000, N'303 Đường C', 'PX001'),
('NV00000007', N'Đỗ', 'G', '01-01-1992', '01-01-2018', '0123456783', 5400000, 1250000, N'404 Đường D', 'PX002'),
('NV00000008', N'Bùi', 'H', '01-01-1975', '01-01-2016', '0123456782', 6100000, 1400000, N'505 Đường E', 'PX003'),
('NV00000009', N'Nguyễn', 'I', '01-01-1988', '01-01-2017', '0123456781', 5700000, 1350000, N'606 Đường F', 'PX004'),
('NV00000010', N'Trần', 'J', '01-01-1993', '01-01-2023', '0123456780', 5800000, 1450000, N'707 Đường G', 'PX005');

SET DATEFORMAT dmy
INSERT INTO DONDATHANG (SoHoaDon,MaKhachHangNo,MaNhanVienNo,NgayDatHang,NgayChuyenHang,NgayGiaoHang,SoNhaTenDuong,MaPXNo)VALUES
('DH00000001', 'KH00000001', 'NV00000001', '01-02-2022','10-02-2022', '20-02-2022', NULL, 'PX001'),
('DH00000002', 'KH00000002', 'NV00000002', GETDATE(), GETDATE()+11, GETDATE()+21, N'456 Đường B', 'PX002'),
('DH00000003', 'KH00000003', 'NV00000003', GETDATE()+15, GETDATE()+20, GETDATE()+21, N'789 Đường C', 'PX003'),
('DH00000004', 'KH00000004', 'NV00000004', GETDATE()+10, GETDATE()+21, GETDATE()+22, N'101 Đường D', 'PX004'),
('DH00000005', 'KH00000005', 'NV00000009', GETDATE(), GETDATE()+13, GETDATE()+23, N'112 Đường E', 'PX005'),
('DH00000006', 'KH00000006', 'NV00000006', GETDATE(), Null, GETDATE()+24, N'131 Đường F', 'PX006'),
('DH00000007', 'KH00000007', 'NV00000006', GETDATE(), GETDATE()+15, GETDATE()+25, N'415 Đường G', 'PX007'),
('DH00000008', 'KH00000008', 'NV00000003', GETDATE(), GETDATE()+16, GETDATE()+26, N'161 Đường H', 'PX008'),
('DH00000009', 'KH00000009', 'NV00000009', GETDATE(), GETDATE()+17, GETDATE()+27, N'718 Đường I', 'PX009'),
('DH00000010', 'KH00000010', 'NV00000010', GETDATE(), null, GETDATE()+28, N'910 Đường J', 'PX010');

--Dữ liệu cho bảng CHITIETDATHANG
INSERT INTO CHITIETDATHANG (SoHoaDonNo, MaHangNo, GiaBan, SoLuong, MucGiamGia) VALUES
('DH00000001', 'MH00000001', 100000, 2, Default),
('DH00000001', 'MH00000002', 200000, 100, Default),
('DH00000002', 'MH00000003', 150000, 3, Default),
('DH00000002', 'MH00000004', 50000, 4, Default),
('DH00000003', 'MH00000005', 80000, 1, Default),
('DH00000003', 'MH00000006', 120000, 100, Default),
('DH00000004', 'MH00000006', 90000, 1, Default),
('DH00000004', 'MH00000008', 70000, 5, Default),
('DH00000005', 'MH00000005', 110000, 100, Default),
('DH00000005', 'MH00000010', 140000, 2, Default);

-----------------------------------------------------------------------------
--Phúc An
-- a.Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
UPDATE DONDATHANG
SET NGAYCHUYENHANG = NGAYDATHANG
WHERE NGAYCHUYENHANG IS NULL;

--b. Tăng số lượng hàng của những mặt hàng do công ty VINAMILK cung cấp lên gấp đôi.
UPDATE MATHANG
SET SOLUONG = SOLUONG * 2
WHERE MaCongTyNo in (SELECT MACONGTY 
						FROM NHACUNGCAP
						WHERE TENCONGTY = 'VINAMILK')

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
SET TenCongTy=NCC.TenCongTy,TenGiaoDich=NCC.TenGiaoDich
FROM NHACUNGCAP as NCC, KHACHHANG K
WHERE NCC.TenCongTy=K.TenCongTy AND NCC.TenGiaoDich=K.TenGiaoDich

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
SET PHUCAP =PhuCap + LuongCB * 0.5
where MaNhanVien in
(Select nv.MaNhanVien
FROM DONDATHANG As DH,CHITIETDATHANG as CTDH,NHANVIEN as NV
WHERE MaNhanVien=DH.MaNhanVienNo And CTDH.SoHoaDonNo=DH.SoHoaDon 
GROUP BY MaNhanVien
HAVING SUM(CTDH.SoLuong) IN (
    SELECT TOP 1 TongSL
    FROM (
        SELECT MaNhanVienNo, SUM(SoLuong) AS TongSL
        FROM DONDATHANG, CHITIETDATHANG
        WHERE SoHoaDonNo = SoHoaDon
        GROUP BY MaNhanVienNo
    ) AS Temp
    ORDER BY TongSL DESC
));

--g. Giảm 25% lương của những nhân viên trong năm 2024 không lập được bất kỳ đơn đặt hàng nào.
UPDATE NHANVIEN
SET LuongCB = LuongCB * 0.75
WHERE MaNhanVien NOT IN (
    SELECT MaNhanVienNo
    FROM DONDATHANG
    WHERE YEAR(NGAYDATHANG) = 2024
);

-----------------------------------Bai Tap Nhanh------------------------------------
-- Câu 1: Họ tên và địa chỉ và năm bắt đầu làm việc của các nhân viên trong công ty
SELECT CONCAT(HO, ' ', TEN) AS HoTen, nv.soNhaTenDuong, YEAR(NgayLamViec) AS NamBatDauLamViec
FROM NHANVIEN as nv, PHUONGXA as px
WHERE nv.maPXNo = px.MaPX;
-- Câu 2: Công ty [Việt Tiến] đã cung cấp những mặt hàng nào?
-- Cập nhật lại tên công ty cho các maNCC 'NCC0000002', 'NCC0000004', 'NCC0000007', 'NCC0000008' thành Việt Tiến
update NHACUNGCAP
set TenCongTy = N'Việt Tiến'
where MaCongTy in ('NCC0000002', 'NCC0000004', 'NCC0000007', 'NCC0000008');

SELECT TenCongTy, Tenhang
FROM MATHANG, NHACUNGCAP
WHERE MaCongTy = MaCongTyNo and MaCongTyNo in ('NCC0000002', 'NCC0000004', 'NCC0000007', 'NCC0000008');

-- Câu3: Hãy cho biết có những khách hàng nào lại chính là đối tác cung cấp hàng của công ty (tức là có cùng tên giao dịch).
SELECT DISTINCT MaKhachHang, KH.TenGiaoDich
FROM KHACHHANG KH, NHACUNGCAP NCC
WHERE KH.TenGiaoDich = NCC.TenGiaoDich;

-- Câu 4: Những nhân viên nào của công ty chưa từng lập bất kỳ một hoá đơn đặt hàng nào?
SELECT distinct NV.MaNhanVien, CONCAT(NV.HO, ' ', NV.TEN) AS HoTen
FROM NHANVIEN NV, DONDATHANG DDH
WHERE NV.MaNhanVien not in (select MaNhanVienNo from DONDATHANG); 

-- Câu 5: Mỗi một nhân viên của công ty đã lập  bao nhiêu đơn đặt hàng (nếu nhân viên chưa hề lập một hoá đơn nào thì cho kết quả là 0)
SELECT CONCAT(NV.HO, ' ', NV.TEN) AS HoTen, 
       (SELECT COUNT(*) 
        FROM DONDATHANG hd 
        WHERE hd.MaNhanVienNo = NV.MaNhanVien) AS SoDonDatHang
FROM NhanVien NV;

-- Câu 6: Cho biết tổng số tiền hàng mà cửa hàng thu được trong mỗi tháng của năm 2024 (thời được gian tính theo ngày đặt hàng).
SELECT MONTH(NgayDatHang) AS Thang, SUM(GiaBan * SoLuong) AS TongSoTien
FROM DONDATHANG , CHITIETDATHANG 
WHERE SoHoaDon = SoHoaDonNo
AND YEAR(NgayDatHang) = 2024
GROUP BY MONTH(NgayDatHang);