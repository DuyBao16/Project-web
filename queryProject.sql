--Cau 1: In danh sach sinh vien da ra truong
SELECT *
FROM SinhVien
WHERE NgayRaTruong IS NOT NULL
ORDER BY MaSinhVien;

--Cau 2: In danh sach lop khoa hoc 2022
SELECT *
FROM Lop
WHERE KhoaHoc = 2022
ORDER BY MaLop;

--Cau 3: In ten, ma giang vien, cac giang vien co ten Anh va nam sinh la 1999
SELECT MaGiangVien, HoTen
FROM GiangVien
WHERE HoTen LIKE'%Anh%' AND date_part('year',NgaySinh) = 1999
ORDER BY HoTen;

--Cau 4: In ma sinh vien, ma lop hoc phan cua sinh vien co diem thi hoac diem qua trinh <4
SELECT MaSinhVien, MaLopHocPhan
FROM BangKetQua
WHERE DiemQuaTrinh <4 OR DiemThi <4
ORDER BY MaSinhVien;

--Cau 5: In ra cac ma mon hoc, ten mon hoc co so tin chi tu 3 tro len
SELECT MonHoc.MaMonHoc, MonHoc.TenMonHoc
FROM MonHoc INNER JOIN ThayDoiMonHoc ON MonHoc.MaMonHoc = ThayDoiMonHoc.MaMonHoc
WHERE ThayDoiMonHoc.SoTinChi >=3;

--Cau 6: In ra thoi gian bat dau, ket thuc dia diem hoc, ma lop hoc phan do giang vien GV01 giang day
SELECT LopHocPhan.MaMonHoc, LopHocPhan.MaLopHocPhan, 
		ThayDoiLopHoc.ThoiGianBatDau, ThayDoiLopHoc.ThoiGianKetThuc,
		ThayDoiLopHoc.DiaDiemHoc
FROM ThayDoiLopHoc INNER JOIN LopHocPhan 
					ON ThayDoiLopHoc.MaLopHocPhan = LopHocPhan.MaLopHocPhan
WHERE LopHocPhan.MaMonHoc IN (SELECT MaMonHoc
							 FROM MonHoc
							 WHERE MaGiangVien ='GV01');
							 
--Cau 7: Tinh tong so tin chi da dang ki cua tung sinh vien, sap xep theo thu tu giam dan
SELECT SinhVien.MaSinhVien, SinhVien.HoTen,
		SUM(ThayDoiMonHoc.SoTinChi) AS TongSoTinChi
FROM SinhVien INNER JOIN (DangKiMonHoc INNER JOIN (LopHocPhan INNER JOIN (MonHoc INNER JOIN ThayDoiMonHoc ON MonHoc.MaMonHoc = ThayDoiMonHoc.MaMonHoc)
					ON MonHoc.MaMonHoc = LopHocPhan.MaMonHoc)
					ON LopHocPhan.MaLopHocPhan = DangKiMonHoc.MaLopHocPhan)
					ON SinhVien.MaSinhVien = DangKiMonHoc.MaSinhVien
GROUP BY SinhVien.MaSinhVien
ORDER BY TongSoTinChi DESC;

--Cau 8: In ra mssv, ho ten, diem trung binh cua cac sinh vien co diem tong ket 
--cao hon diem trung binh cua tung lop hoc phan ma sinh vien do dang hoc
SELECT SinhVien.MaSinhVien, SinhVien.HoTen, LopHocPhan.MaLopHocPhan, AVG(BangKetQua.DiemTongKet) AS DiemTrungBinh
FROM SinhVien INNER JOIN (BangKetQua INNER JOIN LopHocPhan ON LopHocPhan.MaLopHocPhan =BangKetQua.MaLopHocPhan )
				ON SinhVien.MaSinhVien=BangKetQua.MaSinhVien
GROUP BY SinhVien.MaSinhVien, LopHocPhan.MaLopHocPhan
HAVING AVG(BangKetQua.DiemTongKet) > (SELECT AVG(BangKetQua.DiemTongKet)
									 FROM BangKetQua
									 WHERE BangKetQua.MaLopHocPhan=LopHocPhan.MaLopHocPhan)
ORDER BY LopHocPhan.MaLopHocPhan, AVG(BangKetQua.DiemTongKet) DESC;

--Cau 9: Tim cac sinh vien co diem trung binh cao hon diem trung binh cua lop hoc phan trong nam 2023
SELECT SinhVien.MaSinhVien, SinhVien.HoTen, lhp1.MaLopHocPhan,
		AVG(BangKetQua.DiemTongKet) AS DiemTrungBinh
FROM SinhVien INNER JOIN (BangKetQua INNER JOIN (LopHocPhan lhp1 INNER JOIN ThayDoiLopHoc
		ON lhp1.MaLopHocPhan = ThayDoiLopHoc.MaLopHocPhan)
		ON BangKetQua.MaLopHocPhan = lhp1.MaLopHocPhan)
		ON SinhVien.MaSinhVien = BangKetQua.MaSinhVien
WHERE date_part('year',ThayDoiLopHoc.ThoiGianBatDau) = 2023
GROUP BY SinhVien.MaSinhVien, lhp1.MaLopHocPhan
HAVING AVG(BangKetQua.DiemTongKet) > (SELECT SUM(BangKetQua.DiemTongKet)/COUNT(lhp2.*)
									FROM BangKetQua INNER JOIN (LopHocPhan lhp2 INNER JOIN ThayDoiLopHoc 
															   ON lhp2.MaLopHocPhan = ThayDoiLopHoc.MaLopHocPhan)
															   ON BangKetQua.MaLopHocPhan = lhp2.MaLopHocPhan
									WHERE lhp1.MaLopHocPhan = lhp2.MaLopHocPhan AND
											date_part('year',ThayDoiLopHoc.ThoiGianBatDau) = 2023);
											
-- Cau 10: In ra nhung sinh vien co so luong lop hoc phan dang ki nhieu hon 
--trung binh cua cac sinh vien khac
SELECT sv.MaSinhVien, sv.HoTen, COUNT(*) AS SoLuongLopHocPhan
FROM SinhVien sv INNER JOIN (DangKiMonHoc dk INNER JOIN LopHocPhan
							ON dk.MaLopHocPhan = LopHocPhan.MaLopHocPhan)
							ON sv.MaSinhVien = dk.MaSinhVien
WHERE date_part('year',dk.NgayDangKi)=2024
GROUP BY sv.MaSinhVien
HAVING COUNT(*) > (SELECT AVG(SoLuongLopHocPhan)
				  FROM
				  (SELECT sv2.MaSinhVien, COUNT(*) AS SoLuongLopHocPhan
				  FROM SinhVien sv2 INNER JOIN(DangKiMonHoc dk2 INNER JOIN LopHocPhan
											  ON dk2.MaLopHocPhan = LopHocPhan.MaLopHocPhan)
				  								ON sv2.MaSinhVien = dk2.MaSinhVien
				  WHERE date_part('year',dk2.NgayDangKi)=2024
				  GROUP BY sv2.MaSinhVien));

--
